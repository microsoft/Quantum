
%Result = type opaque
%Range = type { i64, i64, i64 }
%Array = type opaque
%Qubit = type opaque
%Tuple = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

@Microsoft__Quantum__Samples__RepeatUntilSuccess__CreateQubitsAndApplySimpleGate = alias { i1, %Result*, i64 }* (i1, i2), { i1, %Result*, i64 }* (i1, i2)* @Microsoft__Quantum__Samples__RepeatUntilSuccess__CreateQubitsAndApplySimpleGate__body

define void @Microsoft__Quantum__Samples__RepeatUntilSuccess__ApplySimpleRUSCircuit__body(%Array* %register) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  %qubit = load %Qubit*, %Qubit** %1, align 8
  call void @__quantum__qis__h__body(%Qubit* %qubit)
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 0)
  %3 = bitcast i8* %2 to %Qubit**
  %qubit__1 = load %Qubit*, %Qubit** %3, align 8
  call void @__quantum__qis__t__body(%Qubit* %qubit__1)
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 0)
  %5 = bitcast i8* %4 to %Qubit**
  %6 = load %Qubit*, %Qubit** %5, align 8
  %7 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 1)
  %8 = bitcast i8* %7 to %Qubit**
  %9 = load %Qubit*, %Qubit** %8, align 8
  call void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %6, %Qubit* %9)
  %10 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 0)
  %11 = bitcast i8* %10 to %Qubit**
  %qubit__2 = load %Qubit*, %Qubit** %11, align 8
  call void @__quantum__qis__h__body(%Qubit* %qubit__2)
  %12 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 0)
  %13 = bitcast i8* %12 to %Qubit**
  %14 = load %Qubit*, %Qubit** %13, align 8
  %15 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 1)
  %16 = bitcast i8* %15 to %Qubit**
  %17 = load %Qubit*, %Qubit** %16, align 8
  call void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %14, %Qubit* %17)
  %18 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 0)
  %19 = bitcast i8* %18 to %Qubit**
  %qubit__3 = load %Qubit*, %Qubit** %19, align 8
  call void @__quantum__qis__t__body(%Qubit* %qubit__3)
  %20 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 0)
  %21 = bitcast i8* %20 to %Qubit**
  %qubit__4 = load %Qubit*, %Qubit** %21, align 8
  call void @__quantum__qis__h__body(%Qubit* %qubit__4)
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 -1)
  ret void
}

declare void @__quantum__rt__array_update_alias_count(%Array*, i64)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__qis__h__body(%Qubit*)

declare void @__quantum__qis__t__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %control, %Qubit* %target) {
entry:
  %__controlQubits__ = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %__controlQubits__, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  store %Qubit* %control, %Qubit** %1, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define { i1, i64 }* @Microsoft__Quantum__Samples__RepeatUntilSuccess__ApplySimpleGate__body(i2 %inputBasis, i1 %inputValue, %Array* %register) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 1)
  %success = alloca i1, align 1
  store i1 false, i1* %success, align 1
  %numIter = alloca i64, align 8
  store i64 0, i64* %numIter, align 4
  br i1 %inputValue, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 1)
  %1 = bitcast i8* %0 to %Qubit**
  %qubit = load %Qubit*, %Qubit** %1, align 8
  call void @__quantum__qis__x__body(%Qubit* %qubit)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 1)
  %3 = bitcast i8* %2 to %Qubit**
  %4 = load %Qubit*, %Qubit** %3, align 8
  call void @Microsoft__Quantum__Preparation__PreparePauliEigenstate__body(i2 %inputBasis, %Qubit* %4)
  br label %repeat__1

repeat__1:                                        ; preds = %fixup__1, %continue__1
  call void @Microsoft__Quantum__Samples__RepeatUntilSuccess__ApplySimpleRUSCircuit__body(%Array* %register)
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 0)
  %6 = bitcast i8* %5 to %Qubit**
  %7 = load %Qubit*, %Qubit** %6, align 8
  %8 = call %Result* @Microsoft__Quantum__Measurement__MResetZ__body(%Qubit* %7)
  %9 = load %Result*, %Result** @ResultZero, align 8
  %10 = call i1 @__quantum__rt__result_equal(%Result* %8, %Result* %9)
  store i1 %10, i1* %success, align 1
  %11 = load i64, i64* %numIter, align 4
  %12 = add i64 %11, 1
  store i64 %12, i64* %numIter, align 4
  br label %until__1

until__1:                                         ; preds = %repeat__1
  br i1 %10, label %rend__1, label %fixup__1

fixup__1:                                         ; preds = %until__1
  call void @__quantum__rt__result_update_reference_count(%Result* %8, i64 -1)
  br label %repeat__1

rend__1:                                          ; preds = %until__1
  call void @__quantum__rt__result_update_reference_count(%Result* %8, i64 -1)
  %13 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i1, i64 }* getelementptr ({ i1, i64 }, { i1, i64 }* null, i32 1) to i64))
  %14 = bitcast %Tuple* %13 to { i1, i64 }*
  %15 = getelementptr inbounds { i1, i64 }, { i1, i64 }* %14, i32 0, i32 0
  %16 = getelementptr inbounds { i1, i64 }, { i1, i64 }* %14, i32 0, i32 1
  %17 = load i1, i1* %success, align 1
  %18 = load i64, i64* %numIter, align 4
  store i1 %17, i1* %15, align 1
  store i64 %18, i64* %16, align 4
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 -1)
  ret { i1, i64 }* %14
}

declare void @__quantum__qis__x__body(%Qubit*)

define void @Microsoft__Quantum__Preparation__PreparePauliEigenstate__body(i2 %basis, %Qubit* %qubit) {
entry:
  %0 = load i2, i2* @PauliI, align 1
  %1 = icmp eq i2 %basis, %0
  br i1 %1, label %then0__1, label %test1__1

then0__1:                                         ; preds = %entry
  call void @Microsoft__Quantum__Preparation__PrepareSingleQubitIdentity__body(%Qubit* %qubit)
  br label %continue__1

test1__1:                                         ; preds = %entry
  %2 = load i2, i2* @PauliX, align 1
  %3 = icmp eq i2 %basis, %2
  br i1 %3, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  call void @__quantum__qis__h__body(%Qubit* %qubit)
  br label %continue__1

test2__1:                                         ; preds = %test1__1
  %4 = load i2, i2* @PauliY, align 1
  %5 = icmp eq i2 %basis, %4
  br i1 %5, label %then2__1, label %continue__1

then2__1:                                         ; preds = %test2__1
  call void @__quantum__qis__h__body(%Qubit* %qubit)
  call void @__quantum__qis__s__body(%Qubit* %qubit)
  br label %continue__1

continue__1:                                      ; preds = %then2__1, %test2__1, %then1__1, %then0__1
  ret void
}

define %Result* @Microsoft__Quantum__Measurement__MResetZ__body(%Qubit* %target) {
entry:
  %result = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %target)
  %0 = load %Result*, %Result** @ResultOne, align 8
  %1 = call i1 @__quantum__rt__result_equal(%Result* %result, %Result* %0)
  br i1 %1, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__x__body(%Qubit* %target)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  ret %Result* %result
}

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare void @__quantum__rt__result_update_reference_count(%Result*, i64)

declare %Tuple* @__quantum__rt__tuple_create(i64)

define { i1, %Result*, i64 }* @Microsoft__Quantum__Samples__RepeatUntilSuccess__CreateQubitsAndApplySimpleGate__body(i1 %inputValue, i2 %inputBasis) #0 {
entry:
  %register = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 1)
  %0 = call { i1, i64 }* @Microsoft__Quantum__Samples__RepeatUntilSuccess__ApplySimpleGate__body(i2 %inputBasis, i1 %inputValue, %Array* %register)
  %1 = getelementptr inbounds { i1, i64 }, { i1, i64 }* %0, i32 0, i32 0
  %success = load i1, i1* %1, align 1
  %2 = getelementptr inbounds { i1, i64 }, { i1, i64 }* %0, i32 0, i32 1
  %numIter = load i64, i64* %2, align 4
  %bases = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 1)
  %3 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases, i64 0)
  %4 = bitcast i8* %3 to i2*
  store i2 %inputBasis, i2* %4, align 1
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 1)
  %qubits = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 0)
  %6 = bitcast i8* %5 to %Qubit**
  %7 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 1)
  %8 = bitcast i8* %7 to %Qubit**
  %9 = load %Qubit*, %Qubit** %8, align 8
  store %Qubit* %9, %Qubit** %6, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %result = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qubits, i64 -1)
  %10 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i1, %Result*, i64 }* getelementptr ({ i1, %Result*, i64 }, { i1, %Result*, i64 }* null, i32 1) to i64))
  %11 = bitcast %Tuple* %10 to { i1, %Result*, i64 }*
  %12 = getelementptr inbounds { i1, %Result*, i64 }, { i1, %Result*, i64 }* %11, i32 0, i32 0
  %13 = getelementptr inbounds { i1, %Result*, i64 }, { i1, %Result*, i64 }* %11, i32 0, i32 1
  %14 = getelementptr inbounds { i1, %Result*, i64 }, { i1, %Result*, i64 }* %11, i32 0, i32 2
  store i1 %success, i1* %12, align 1
  store %Result* %result, %Result** %13, align 8
  store i64 %numIter, i64* %14, align 4
  call void @__quantum__rt__qubit_release_array(%Array* %register)
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %register, i64 -1)
  %15 = bitcast { i1, i64 }* %0 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %15, i64 -1)
  ret { i1, %Result*, i64 }* %11
}

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare %Result* @__quantum__qis__measure__body(%Array*, %Array*)

declare void @__quantum__rt__array_update_reference_count(%Array*, i64)

declare void @__quantum__rt__qubit_release_array(%Array*)

declare void @__quantum__rt__tuple_update_reference_count(%Tuple*, i64)

define i64 @Microsoft__Quantum__Random__DrawRandomInt__body(i64 %min, i64 %max) {
entry:
  %0 = call i64 @__quantum__qis__drawrandomint__body(i64 %min, i64 %max)
  ret i64 %0
}

declare i64 @__quantum__qis__drawrandomint__body(i64, i64)

define i2 @Microsoft__Quantum__Random__DrawRandomPauli__body() {
entry:
  %0 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %1 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 0)
  %2 = bitcast i8* %1 to i2*
  %3 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 1)
  %4 = bitcast i8* %3 to i2*
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 2)
  %6 = bitcast i8* %5 to i2*
  %7 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 3)
  %8 = bitcast i8* %7 to i2*
  %9 = load i2, i2* @PauliI, align 1
  %10 = load i2, i2* @PauliX, align 1
  %11 = load i2, i2* @PauliY, align 1
  %12 = load i2, i2* @PauliZ, align 1
  store i2 %9, i2* %2, align 1
  store i2 %10, i2* %4, align 1
  store i2 %11, i2* %6, align 1
  store i2 %12, i2* %8, align 1
  %13 = call i64 @__quantum__qis__drawrandomint__body(i64 0, i64 3)
  %14 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 %13)
  %15 = bitcast i8* %14 to i2*
  %16 = load i2, i2* %15, align 1
  call void @__quantum__rt__array_update_reference_count(%Array* %0, i64 -1)
  ret i2 %16
}

define %Range @Microsoft__Quantum__Arrays___0d6b0737cfca4139baad74fa2712e921_IndexRange__body(%Array* %array) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i64 1)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %array)
  %1 = sub i64 %0, 1
  %2 = load %Range, %Range* @EmptyRange, align 4
  %3 = insertvalue %Range %2, i64 0, 0
  %4 = insertvalue %Range %3, i64 1, 1
  %5 = insertvalue %Range %4, i64 %1, 2
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i64 -1)
  ret %Range %5
}

declare i64 @__quantum__rt__array_get_size_1d(%Array*)

declare void @__quantum__qis__x__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__CNOT__adj(%Qubit* %control, %Qubit* %target) {
entry:
  call void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %control, %Qubit* %target)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__CNOT__ctl(%Array* %__controlQubits__, { %Qubit*, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %0, i32 0, i32 0
  %control = load %Qubit*, %Qubit** %1, align 8
  %2 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %0, i32 0, i32 1
  %target = load %Qubit*, %Qubit** %2, align 8
  %3 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %3, i64 0)
  %5 = bitcast i8* %4 to %Qubit**
  store %Qubit* %control, %Qubit** %5, align 8
  %__controlQubits__1 = call %Array* @__quantum__rt__array_concatenate(%Array* %__controlQubits__, %Array* %3)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__1, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__1, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__1, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %3, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %__controlQubits__1, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare %Array* @__quantum__rt__array_concatenate(%Array*, %Array*)

define void @Microsoft__Quantum__Intrinsic__CNOT__ctladj(%Array* %__controlQubits__, { %Qubit*, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %0, i32 0, i32 0
  %control = load %Qubit*, %Qubit** %1, align 8
  %2 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %0, i32 0, i32 1
  %target = load %Qubit*, %Qubit** %2, align 8
  %3 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %4 = bitcast %Tuple* %3 to { %Qubit*, %Qubit* }*
  %5 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %4, i32 0, i32 0
  %6 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %4, i32 0, i32 1
  store %Qubit* %control, %Qubit** %5, align 8
  store %Qubit* %target, %Qubit** %6, align 8
  call void @Microsoft__Quantum__Intrinsic__CNOT__ctl(%Array* %__controlQubits__, { %Qubit*, %Qubit* }* %4)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %3, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__h__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__h__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__h__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__h__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__H__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__h__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %qubit) {
entry:
  %bases = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases, i64 0)
  %1 = bitcast i8* %0 to i2*
  %2 = load i2, i2* @PauliZ, align 1
  store i2 %2, i2* %1, align 1
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 1)
  %qubits = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %3 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 0)
  %4 = bitcast i8* %3 to %Qubit**
  store %Qubit* %qubit, %Qubit** %4, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %5 = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qubits, i64 -1)
  ret %Result* %5
}

define void @Microsoft__Quantum__Intrinsic__Z__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__z__body(%Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__z__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__Z__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__z__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__z__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__z__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__Z__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__z__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__x__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__x__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__t__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__t__adj(%Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__t__adj(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__T__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__t__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__t__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__T__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__t__ctladj(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__t__ctladj(%Array*, %Qubit*)

define %Result* @Microsoft__Quantum__Intrinsic__Measure__body(%Array* %bases, %Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %0 = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  ret %Result* %0
}

define void @Microsoft__Quantum__Intrinsic__S__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__s__body(%Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__s__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__S__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__s__adj(%Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__s__adj(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__S__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__s__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__s__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__S__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__s__ctladj(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__s__ctladj(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__Y__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__y__body(%Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__y__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__Y__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__y__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__y__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__y__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__Y__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__y__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Canon__ApplyPauli__body(%Array* %pauli, %Array* %target) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %pauli, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %target, i64 1)
  %0 = call %Range @Microsoft__Quantum__Arrays___0d6b0737cfca4139baad74fa2712e921_IndexRange__body(%Array* %pauli)
  %1 = extractvalue %Range %0, 0
  %2 = extractvalue %Range %0, 1
  %3 = extractvalue %Range %0, 2
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  %4 = icmp sgt i64 %2, 0
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %idxPauli = phi i64 [ %1, %preheader__1 ], [ %18, %exiting__1 ]
  %5 = icmp sle i64 %idxPauli, %3
  %6 = icmp sge i64 %idxPauli, %3
  %7 = select i1 %4, i1 %5, i1 %6
  br i1 %7, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %8 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %pauli, i64 %idxPauli)
  %9 = bitcast i8* %8 to i2*
  %P = load i2, i2* %9, align 1
  %10 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %target, i64 %idxPauli)
  %11 = bitcast i8* %10 to %Qubit**
  %targ = load %Qubit*, %Qubit** %11, align 8
  %12 = load i2, i2* @PauliX, align 1
  %13 = icmp eq i2 %P, %12
  br i1 %13, label %then0__1, label %test1__1

then0__1:                                         ; preds = %body__1
  call void @__quantum__qis__x__body(%Qubit* %targ)
  br label %continue__1

test1__1:                                         ; preds = %body__1
  %14 = load i2, i2* @PauliY, align 1
  %15 = icmp eq i2 %P, %14
  br i1 %15, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  call void @__quantum__qis__y__body(%Qubit* %targ)
  br label %continue__1

test2__1:                                         ; preds = %test1__1
  %16 = load i2, i2* @PauliZ, align 1
  %17 = icmp eq i2 %P, %16
  br i1 %17, label %then2__1, label %continue__1

then2__1:                                         ; preds = %test2__1
  call void @__quantum__qis__z__body(%Qubit* %targ)
  br label %continue__1

continue__1:                                      ; preds = %then2__1, %test2__1, %then1__1, %then0__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %18 = add i64 %idxPauli, %2
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %pauli, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %target, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Canon__ApplyPauli__adj(%Array* %pauli, %Array* %target) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %pauli, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %target, i64 1)
  %0 = call %Range @Microsoft__Quantum__Arrays___0d6b0737cfca4139baad74fa2712e921_IndexRange__body(%Array* %pauli)
  %1 = extractvalue %Range %0, 0
  %2 = extractvalue %Range %0, 1
  %3 = extractvalue %Range %0, 2
  %4 = sub i64 %3, %1
  %5 = udiv i64 %4, %2
  %6 = mul i64 %2, %5
  %7 = add i64 %1, %6
  %8 = load %Range, %Range* @EmptyRange, align 4
  %9 = insertvalue %Range %8, i64 %7, 0
  %10 = sub i64 0, %2
  %11 = insertvalue %Range %9, i64 %10, 1
  %12 = insertvalue %Range %11, i64 %1, 2
  %13 = extractvalue %Range %12, 0
  %14 = extractvalue %Range %12, 1
  %15 = extractvalue %Range %12, 2
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  %16 = icmp sgt i64 %14, 0
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %__qsVar0__idxPauli__ = phi i64 [ %13, %preheader__1 ], [ %30, %exiting__1 ]
  %17 = icmp sle i64 %__qsVar0__idxPauli__, %15
  %18 = icmp sge i64 %__qsVar0__idxPauli__, %15
  %19 = select i1 %16, i1 %17, i1 %18
  br i1 %19, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %20 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %pauli, i64 %__qsVar0__idxPauli__)
  %21 = bitcast i8* %20 to i2*
  %__qsVar1__P__ = load i2, i2* %21, align 1
  %22 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %target, i64 %__qsVar0__idxPauli__)
  %23 = bitcast i8* %22 to %Qubit**
  %__qsVar2__targ__ = load %Qubit*, %Qubit** %23, align 8
  %24 = load i2, i2* @PauliX, align 1
  %25 = icmp eq i2 %__qsVar1__P__, %24
  br i1 %25, label %then0__1, label %test1__1

then0__1:                                         ; preds = %body__1
  call void @__quantum__qis__x__body(%Qubit* %__qsVar2__targ__)
  br label %continue__1

test1__1:                                         ; preds = %body__1
  %26 = load i2, i2* @PauliY, align 1
  %27 = icmp eq i2 %__qsVar1__P__, %26
  br i1 %27, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  call void @__quantum__qis__y__body(%Qubit* %__qsVar2__targ__)
  br label %continue__1

test2__1:                                         ; preds = %test1__1
  %28 = load i2, i2* @PauliZ, align 1
  %29 = icmp eq i2 %__qsVar1__P__, %28
  br i1 %29, label %then2__1, label %continue__1

then2__1:                                         ; preds = %test2__1
  call void @__quantum__qis__z__body(%Qubit* %__qsVar2__targ__)
  br label %continue__1

continue__1:                                      ; preds = %then2__1, %test2__1, %then1__1, %then0__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %30 = add i64 %__qsVar0__idxPauli__, %14
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %pauli, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %target, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Canon__ApplyPauli__ctl(%Array* %__controlQubits__, { %Array*, %Array* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %0, i32 0, i32 0
  %pauli = load %Array*, %Array** %1, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %pauli, i64 1)
  %2 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %0, i32 0, i32 1
  %target = load %Array*, %Array** %2, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %target, i64 1)
  %3 = call %Range @Microsoft__Quantum__Arrays___0d6b0737cfca4139baad74fa2712e921_IndexRange__body(%Array* %pauli)
  %4 = extractvalue %Range %3, 0
  %5 = extractvalue %Range %3, 1
  %6 = extractvalue %Range %3, 2
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  %7 = icmp sgt i64 %5, 0
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %idxPauli = phi i64 [ %4, %preheader__1 ], [ %21, %exiting__1 ]
  %8 = icmp sle i64 %idxPauli, %6
  %9 = icmp sge i64 %idxPauli, %6
  %10 = select i1 %7, i1 %8, i1 %9
  br i1 %10, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %11 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %pauli, i64 %idxPauli)
  %12 = bitcast i8* %11 to i2*
  %P = load i2, i2* %12, align 1
  %13 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %target, i64 %idxPauli)
  %14 = bitcast i8* %13 to %Qubit**
  %targ = load %Qubit*, %Qubit** %14, align 8
  %15 = load i2, i2* @PauliX, align 1
  %16 = icmp eq i2 %P, %15
  br i1 %16, label %then0__1, label %test1__1

then0__1:                                         ; preds = %body__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %targ)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %continue__1

test1__1:                                         ; preds = %body__1
  %17 = load i2, i2* @PauliY, align 1
  %18 = icmp eq i2 %P, %17
  br i1 %18, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__y__ctl(%Array* %__controlQubits__, %Qubit* %targ)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %continue__1

test2__1:                                         ; preds = %test1__1
  %19 = load i2, i2* @PauliZ, align 1
  %20 = icmp eq i2 %P, %19
  br i1 %20, label %then2__1, label %continue__1

then2__1:                                         ; preds = %test2__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__z__ctl(%Array* %__controlQubits__, %Qubit* %targ)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %continue__1

continue__1:                                      ; preds = %then2__1, %test2__1, %then1__1, %then0__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %21 = add i64 %idxPauli, %5
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %pauli, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %target, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Canon__ApplyPauli__ctladj(%Array* %__controlQubits__, { %Array*, %Array* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %0, i32 0, i32 0
  %pauli = load %Array*, %Array** %1, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %pauli, i64 1)
  %2 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %0, i32 0, i32 1
  %target = load %Array*, %Array** %2, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %target, i64 1)
  %3 = call %Range @Microsoft__Quantum__Arrays___0d6b0737cfca4139baad74fa2712e921_IndexRange__body(%Array* %pauli)
  %4 = extractvalue %Range %3, 0
  %5 = extractvalue %Range %3, 1
  %6 = extractvalue %Range %3, 2
  %7 = sub i64 %6, %4
  %8 = udiv i64 %7, %5
  %9 = mul i64 %5, %8
  %10 = add i64 %4, %9
  %11 = load %Range, %Range* @EmptyRange, align 4
  %12 = insertvalue %Range %11, i64 %10, 0
  %13 = sub i64 0, %5
  %14 = insertvalue %Range %12, i64 %13, 1
  %15 = insertvalue %Range %14, i64 %4, 2
  %16 = extractvalue %Range %15, 0
  %17 = extractvalue %Range %15, 1
  %18 = extractvalue %Range %15, 2
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  %19 = icmp sgt i64 %17, 0
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %__qsVar0__idxPauli__ = phi i64 [ %16, %preheader__1 ], [ %33, %exiting__1 ]
  %20 = icmp sle i64 %__qsVar0__idxPauli__, %18
  %21 = icmp sge i64 %__qsVar0__idxPauli__, %18
  %22 = select i1 %19, i1 %20, i1 %21
  br i1 %22, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %23 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %pauli, i64 %__qsVar0__idxPauli__)
  %24 = bitcast i8* %23 to i2*
  %__qsVar1__P__ = load i2, i2* %24, align 1
  %25 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %target, i64 %__qsVar0__idxPauli__)
  %26 = bitcast i8* %25 to %Qubit**
  %__qsVar2__targ__ = load %Qubit*, %Qubit** %26, align 8
  %27 = load i2, i2* @PauliX, align 1
  %28 = icmp eq i2 %__qsVar1__P__, %27
  br i1 %28, label %then0__1, label %test1__1

then0__1:                                         ; preds = %body__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %__qsVar2__targ__)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %continue__1

test1__1:                                         ; preds = %body__1
  %29 = load i2, i2* @PauliY, align 1
  %30 = icmp eq i2 %__qsVar1__P__, %29
  br i1 %30, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__y__ctl(%Array* %__controlQubits__, %Qubit* %__qsVar2__targ__)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %continue__1

test2__1:                                         ; preds = %test1__1
  %31 = load i2, i2* @PauliZ, align 1
  %32 = icmp eq i2 %__qsVar1__P__, %31
  br i1 %32, label %then2__1, label %continue__1

then2__1:                                         ; preds = %test2__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__z__ctl(%Array* %__controlQubits__, %Qubit* %__qsVar2__targ__)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %continue__1

continue__1:                                      ; preds = %then2__1, %test2__1, %then1__1, %then0__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %33 = add i64 %__qsVar0__idxPauli__, %17
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %pauli, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %target, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Preparation__PrepareSingleQubitIdentity__body(%Qubit* %qubit) {
entry:
  %0 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 1)
  %1 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 0)
  %2 = bitcast i8* %1 to i2*
  %3 = call i2 @Microsoft__Quantum__Random__DrawRandomPauli__body()
  store i2 %3, i2* %2, align 1
  %4 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %4, i64 0)
  %6 = bitcast i8* %5 to %Qubit**
  store %Qubit* %qubit, %Qubit** %6, align 8
  call void @Microsoft__Quantum__Canon__ApplyPauli__body(%Array* %0, %Array* %4)
  call void @__quantum__rt__array_update_reference_count(%Array* %0, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %4, i64 -1)
  ret void
}

attributes #0 = { "EntryPoint" }
