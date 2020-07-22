"control.Natx" use
"control.Ref" use
"control.drop" use
"control.pfunc" use
"control.when" use
"control.while" use

fieldIsRef: [drop drop FALSE];
fieldIsRef: [index: object:;; index @object @ Ref index @object ! TRUE] [drop drop TRUE] pfunc;
fieldIsref: [isConst] [0 .ERROR_CAN_ONLY_HANDLE_MUTABLE_OBJECTS] pfunc;

cloneField: [
  index: object:;;
  index @object @ index @object fieldIsRef [Ref] [newVarOfTheSameType] if
];

interface: [
  virtual methods: call Ref;
  index: 0;
  inputIndex: 0;

  fillInputs: [
    inputIndex index @methods @ fieldCount 1 - = [] [
      inputIndex index @methods @ cloneField index @methods @ inputIndex fieldName def
      inputIndex 1 + !inputIndex
      @fillInputs ucall
    ] uif
  ];

  fillVtable: [
    index @methods fieldCount = [] [
      {
        self: Natx;
        0 !inputIndex
        @fillInputs ucall
      }

      index @methods @ fieldCount 1 - index @methods @ cloneField
      {} codeRef
      @methods index fieldName def
      index 1 + !index
      @fillVtable ucall
    ] uif
  ];

  {
    Vtable: {
      DIE_FUNC: {self: Natx;} {} {} codeRef;
      [drop] !DIE_FUNC
      SIZE: {self: Natx;} Natx {} codeRef;
      @fillVtable ucall
    };

    CALL: [
      fillMethods: [
        index @Vtable fieldCount = [] [
          @Vtable index fieldName "CALL" = [
            [@closure storageAddress @vtable.CALL]
          ] [
            {
              virtual NAME: @Vtable index fieldName;
              CALL: [@self storageAddress @vtable NAME callField];
            }
          ] if

          @Vtable index fieldName def
          index 1 + !index
          @fillMethods ucall
        ] uif
      ];

      index: 1;

      {
        vtable: @Vtable;
        DIE: [@closure storageAddress @vtable.DIE_FUNC];
        @fillMethods ucall
      }
    ];
  }
];

implement: [
  getBase: getObject:;;

  {
    virtual Base: getBase Ref;
    virtual getObject: @getObject;
    vtable: @Base.@vtable newVarOfTheSameType;

    CALL: [
      moveFields: [
        index @object fieldCount = [] [
          index @object @ index @object fieldIsRef ~ [move copy] when @object index fieldName def
          index 1 + !index
          @moveFields ucall
        ] uif
      ];

      object: getObject;
      index: 0;

      {
        base: {
          virtual Base: @Base;
          vtable: @vtable;
          CALL: [@self storageAddress @Base addressToReference];
        };

        @moveFields ucall
      }
    ];

    [
      virtual Object: CALL Ref;
      [@Object addressToReference manuallyDestroyVariable] @vtable.!DIE_FUNC
      [drop @Object storageSize] @vtable.!SIZE
      i: 2; [i @vtable fieldCount = ~] [
        virtual NAME: @vtable i fieldName;
        [@Object addressToReference NAME callField] i @vtable !
        i 1 + !i
      ] while
    ] call
  }
];