
%Result = type opaque
%Range = type { i64, i64, i64 }
%Tuple = type opaque
%Array = type opaque
%Callable = type opaque
%Qubit = type opaque
%String = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
@Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__ctladj__wrapper]
@PartialApplication__1 = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__ctladj__wrapper]
@MemoryManagement__1 = constant [2 x void (%Tuple*, i64)*] [void (%Tuple*, i64)* @MemoryManagement__1__RefCount, void (%Tuple*, i64)* @MemoryManagement__1__AliasCount]
@0 = internal constant [13 x i8] c"\0A\09Expected:\09\00"
@1 = internal constant [11 x i8] c"\0A\09Actual:\09\00"
@2 = internal constant [39 x i8] c"Array must be of the length at least 1\00"

@Microsoft__Quantum__Samples__PhaseEstimation__RunProgram = alias double (double, i64, i64), double (double, i64, i64)* @Microsoft__Quantum__Samples__PhaseEstimation__RunProgram__body

define double @Microsoft__Quantum__Samples__PhaseEstimation__Integrated__body(%Array* %xs, %Array* %ys) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %xs, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ys, i64 1)
  %sum = alloca double, align 8
  store double 0.000000e+00, double* %sum, align 8
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %xs)
  %1 = sub i64 %0, 2
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %idxPoint = phi i64 [ 0, %entry ], [ %21, %exiting__1 ]
  %2 = icmp sle i64 %idxPoint, %1
  br i1 %2, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %3 = add i64 %idxPoint, 1
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ys, i64 %3)
  %5 = bitcast i8* %4 to double*
  %6 = load double, double* %5, align 8
  %7 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ys, i64 %idxPoint)
  %8 = bitcast i8* %7 to double*
  %9 = load double, double* %8, align 8
  %10 = fadd double %6, %9
  %trapezoidalHeight = fmul double %10, 5.000000e-01
  %11 = add i64 %idxPoint, 1
  %12 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %xs, i64 %11)
  %13 = bitcast i8* %12 to double*
  %14 = load double, double* %13, align 8
  %15 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %xs, i64 %idxPoint)
  %16 = bitcast i8* %15 to double*
  %17 = load double, double* %16, align 8
  %trapezoidalBase = fsub double %14, %17
  %18 = load double, double* %sum, align 8
  %19 = fmul double %trapezoidalBase, %trapezoidalHeight
  %20 = fadd double %18, %19
  store double %20, double* %sum, align 8
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %21 = add i64 %idxPoint, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %22 = load double, double* %sum, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %xs, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ys, i64 -1)
  ret double %22
}

declare void @__quantum__rt__array_update_alias_count(%Array*, i64)

declare i64 @__quantum__rt__array_get_size_1d(%Array*)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

define %Array* @Microsoft__Quantum__Samples__PhaseEstimation__PointwiseProduct__body(%Array* %left, %Array* %right) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %left, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %right, i64 1)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %left)
  %1 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %0)
  %2 = sub i64 %0, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %3 = phi i64 [ 0, %entry ], [ %7, %exiting__1 ]
  %4 = icmp sle i64 %3, %2
  br i1 %4, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %1, i64 %3)
  %6 = bitcast i8* %5 to double*
  store double 0.000000e+00, double* %6, align 8
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %7 = add i64 %3, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %product = alloca %Array*, align 8
  store %Array* %1, %Array** %product, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %1, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %1, i64 1)
  %8 = call %Range @Microsoft__Quantum__Arrays___35831c169e934b61bf2d4e6f17d0b819_IndexRange__body(%Array* %left)
  %9 = extractvalue %Range %8, 0
  %10 = extractvalue %Range %8, 1
  %11 = extractvalue %Range %8, 2
  br label %preheader__1

preheader__1:                                     ; preds = %exit__1
  %12 = icmp sgt i64 %10, 0
  br label %header__2

header__2:                                        ; preds = %exiting__2, %preheader__1
  %idxElement = phi i64 [ %9, %preheader__1 ], [ %28, %exiting__2 ]
  %13 = icmp sle i64 %idxElement, %11
  %14 = icmp sge i64 %idxElement, %11
  %15 = select i1 %12, i1 %13, i1 %14
  br i1 %15, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %16 = load %Array*, %Array** %product, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %16, i64 -1)
  %17 = call %Array* @__quantum__rt__array_copy(%Array* %16, i1 false)
  %18 = icmp ne %Array* %16, %17
  %19 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %left, i64 %idxElement)
  %20 = bitcast i8* %19 to double*
  %21 = load double, double* %20, align 8
  %22 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %right, i64 %idxElement)
  %23 = bitcast i8* %22 to double*
  %24 = load double, double* %23, align 8
  %25 = fmul double %21, %24
  %26 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %17, i64 %idxElement)
  %27 = bitcast i8* %26 to double*
  store double %25, double* %27, align 8
  call void @__quantum__rt__array_update_reference_count(%Array* %17, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %17, i64 1)
  store %Array* %17, %Array** %product, align 8
  call void @__quantum__rt__array_update_reference_count(%Array* %16, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %17, i64 -1)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %28 = add i64 %idxElement, %10
  br label %header__2

exit__2:                                          ; preds = %header__2
  %29 = load %Array*, %Array** %product, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %left, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %right, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %29, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %1, i64 -1)
  ret %Array* %29
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare void @__quantum__rt__array_update_reference_count(%Array*, i64)

define %Range @Microsoft__Quantum__Arrays___35831c169e934b61bf2d4e6f17d0b819_IndexRange__body(%Array* %array) {
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

declare %Array* @__quantum__rt__array_copy(%Array*, i1)

define %Result* @Microsoft__Quantum__Samples__PhaseEstimation__ApplyIterativePhaseEstimationStep__body(double %time, double %inversionAngle, %Callable* %oracle, %Array* %eigenstate) {
entry:
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %oracle, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %oracle, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %eigenstate, i64 1)
  %0 = load %Result*, %Result** @ResultZero, align 8
  %result = alloca %Result*, align 8
  store %Result* %0, %Result** %result, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %0, i64 1)
  %controlQubit = call %Qubit* @__quantum__rt__qubit_allocate()
  call void @__quantum__qis__h__body(%Qubit* %controlQubit)
  %1 = fneg double %time
  %2 = fmul double %1, %inversionAngle
  call void @Microsoft__Quantum__Intrinsic__Rz__body(double %2, %Qubit* %controlQubit)
  %3 = call %Callable* @__quantum__rt__callable_copy(%Callable* %oracle, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %3, i64 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %3)
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %5 = bitcast %Tuple* %4 to { %Array*, { double, %Array* }* }*
  %6 = getelementptr inbounds { %Array*, { double, %Array* }* }, { %Array*, { double, %Array* }* }* %5, i32 0, i32 0
  %7 = getelementptr inbounds { %Array*, { double, %Array* }* }, { %Array*, { double, %Array* }* }* %5, i32 0, i32 1
  %8 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %9 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %8, i64 0)
  %10 = bitcast i8* %9 to %Qubit**
  store %Qubit* %controlQubit, %Qubit** %10, align 8
  %11 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ double, %Array* }* getelementptr ({ double, %Array* }, { double, %Array* }* null, i32 1) to i64))
  %12 = bitcast %Tuple* %11 to { double, %Array* }*
  %13 = getelementptr inbounds { double, %Array* }, { double, %Array* }* %12, i32 0, i32 0
  %14 = getelementptr inbounds { double, %Array* }, { double, %Array* }* %12, i32 0, i32 1
  store double %time, double* %13, align 8
  store %Array* %eigenstate, %Array** %14, align 8
  call void @__quantum__rt__array_update_reference_count(%Array* %eigenstate, i64 1)
  store %Array* %8, %Array** %6, align 8
  store { double, %Array* }* %12, { double, %Array* }** %7, align 8
  call void @__quantum__rt__callable_invoke(%Callable* %3, %Tuple* %4, %Tuple* null)
  %15 = call %Result* @Microsoft__Quantum__Measurement__MResetX__body(%Qubit* %controlQubit)
  call void @__quantum__rt__qubit_release(%Qubit* %controlQubit)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %oracle, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %oracle, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %eigenstate, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %3, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %8, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %eigenstate, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %11, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %0, i64 -1)
  ret %Result* %15
}

declare void @__quantum__rt__callable_memory_management(i32, %Callable*, i64)

declare void @__quantum__rt__callable_update_alias_count(%Callable*, i64)

declare void @__quantum__rt__result_update_reference_count(%Result*, i64)

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare void @__quantum__qis__h__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__Rz__body(double %theta, %Qubit* %qubit) {
entry:
  %pauli = load i2, i2* @PauliZ, align 1
  call void @__quantum__qis__r__body(i2 %pauli, double %theta, %Qubit* %qubit)
  ret void
}

declare void @__quantum__rt__callable_invoke(%Callable*, %Tuple*, %Tuple*)

declare %Callable* @__quantum__rt__callable_copy(%Callable*, i1)

declare void @__quantum__rt__callable_make_controlled(%Callable*)

declare %Tuple* @__quantum__rt__tuple_create(i64)

define %Result* @Microsoft__Quantum__Measurement__MResetX__body(%Qubit* %target) {
entry:
  %bases = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases, i64 0)
  %1 = bitcast i8* %0 to i2*
  %2 = load i2, i2* @PauliX, align 1
  store i2 %2, i2* %1, align 1
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 1)
  %qubits = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %3 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 0)
  %4 = bitcast i8* %3 to %Qubit**
  store %Qubit* %target, %Qubit** %4, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %result = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qubits, i64 -1)
  call void @__quantum__qis__h__body(%Qubit* %target)
  %5 = load %Result*, %Result** @ResultOne, align 8
  %6 = call i1 @__quantum__rt__result_equal(%Result* %result, %Result* %5)
  br i1 %6, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__x__body(%Qubit* %target)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  ret %Result* %result
}

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__callable_update_reference_count(%Callable*, i64)

declare void @__quantum__rt__tuple_update_reference_count(%Tuple*, i64)

define double @Microsoft__Quantum__Samples__PhaseEstimation__RunProgram__body(double %eigenphase, i64 %nGridPoints, i64 %nMeasurements) #0 {
entry:
  %0 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Callable*, double }* getelementptr ({ %Callable*, double }, { %Callable*, double }* null, i32 1) to i64))
  %1 = bitcast %Tuple* %0 to { %Callable*, double }*
  %2 = getelementptr inbounds { %Callable*, double }, { %Callable*, double }* %1, i32 0, i32 0
  %3 = getelementptr inbounds { %Callable*, double }, { %Callable*, double }* %1, i32 0, i32 1
  %4 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  store %Callable* %4, %Callable** %2, align 8
  store double %eigenphase, double* %3, align 8
  %oracle = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @PartialApplication__1, [2 x void (%Tuple*, i64)*]* @MemoryManagement__1, %Tuple* %0)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %oracle, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %oracle, i64 1)
  %eigenstate = call %Qubit* @__quantum__rt__qubit_allocate()
  call void @__quantum__qis__x__body(%Qubit* %eigenstate)
  %5 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %5, i64 0)
  %7 = bitcast i8* %6 to %Qubit**
  store %Qubit* %eigenstate, %Qubit** %7, align 8
  %est = call double @Microsoft__Quantum__Samples__PhaseEstimation__EstimatePhase__body(i64 %nGridPoints, i64 %nMeasurements, %Callable* %oracle, %Array* %5)
  call void @Microsoft__Quantum__Intrinsic__Reset__body(%Qubit* %eigenstate)
  call void @__quantum__rt__qubit_release(%Qubit* %eigenstate)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %oracle, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %oracle, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %5, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %oracle, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %oracle, i64 -1)
  ret double %est
}

define void @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { double, double, %Array* }*
  %1 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %0, i32 0, i32 1
  %3 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %0, i32 0, i32 2
  %4 = load double, double* %1, align 8
  %5 = load double, double* %2, align 8
  %6 = load %Array*, %Array** %3, align 8
  call void @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__body(double %4, double %5, %Array* %6)
  ret void
}

define void @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { double, double, %Array* }*
  %1 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %0, i32 0, i32 1
  %3 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %0, i32 0, i32 2
  %4 = load double, double* %1, align 8
  %5 = load double, double* %2, align 8
  %6 = load %Array*, %Array** %3, align 8
  call void @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__adj(double %4, double %5, %Array* %6)
  ret void
}

define void @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { double, double, %Array* }* }*
  %1 = getelementptr inbounds { %Array*, { double, double, %Array* }* }, { %Array*, { double, double, %Array* }* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, { double, double, %Array* }* }, { %Array*, { double, double, %Array* }* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load { double, double, %Array* }*, { double, double, %Array* }** %2, align 8
  call void @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__ctl(%Array* %3, { double, double, %Array* }* %4)
  ret void
}

define void @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { double, double, %Array* }* }*
  %1 = getelementptr inbounds { %Array*, { double, double, %Array* }* }, { %Array*, { double, double, %Array* }* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, { double, double, %Array* }* }, { %Array*, { double, double, %Array* }* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load { double, double, %Array* }*, { double, double, %Array* }** %2, align 8
  call void @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__ctladj(%Array* %3, { double, double, %Array* }* %4)
  ret void
}

declare %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]*, [2 x void (%Tuple*, i64)*]*, %Tuple*)

define void @Lifted__PartialApplication__1__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, double }*
  %1 = getelementptr inbounds { %Callable*, double }, { %Callable*, double }* %0, i32 0, i32 1
  %2 = load double, double* %1, align 8
  %3 = bitcast %Tuple* %arg-tuple to { double, %Array* }*
  %4 = getelementptr inbounds { double, %Array* }, { double, %Array* }* %3, i32 0, i32 0
  %5 = load double, double* %4, align 8
  %6 = getelementptr inbounds { double, %Array* }, { double, %Array* }* %3, i32 0, i32 1
  %7 = load %Array*, %Array** %6, align 8
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ double, double, %Array* }* getelementptr ({ double, double, %Array* }, { double, double, %Array* }* null, i32 1) to i64))
  %9 = bitcast %Tuple* %8 to { double, double, %Array* }*
  %10 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %9, i32 0, i32 0
  %11 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %9, i32 0, i32 1
  %12 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %9, i32 0, i32 2
  store double %2, double* %10, align 8
  store double %5, double* %11, align 8
  store %Array* %7, %Array** %12, align 8
  %13 = getelementptr inbounds { %Callable*, double }, { %Callable*, double }* %0, i32 0, i32 0
  %14 = load %Callable*, %Callable** %13, align 8
  call void @__quantum__rt__callable_invoke(%Callable* %14, %Tuple* %8, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i64 -1)
  ret void
}

define void @Lifted__PartialApplication__1__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, double }*
  %1 = getelementptr inbounds { %Callable*, double }, { %Callable*, double }* %0, i32 0, i32 1
  %2 = load double, double* %1, align 8
  %3 = bitcast %Tuple* %arg-tuple to { double, %Array* }*
  %4 = getelementptr inbounds { double, %Array* }, { double, %Array* }* %3, i32 0, i32 0
  %5 = load double, double* %4, align 8
  %6 = getelementptr inbounds { double, %Array* }, { double, %Array* }* %3, i32 0, i32 1
  %7 = load %Array*, %Array** %6, align 8
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ double, double, %Array* }* getelementptr ({ double, double, %Array* }, { double, double, %Array* }* null, i32 1) to i64))
  %9 = bitcast %Tuple* %8 to { double, double, %Array* }*
  %10 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %9, i32 0, i32 0
  %11 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %9, i32 0, i32 1
  %12 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %9, i32 0, i32 2
  store double %2, double* %10, align 8
  store double %5, double* %11, align 8
  store %Array* %7, %Array** %12, align 8
  %13 = getelementptr inbounds { %Callable*, double }, { %Callable*, double }* %0, i32 0, i32 0
  %14 = load %Callable*, %Callable** %13, align 8
  %15 = call %Callable* @__quantum__rt__callable_copy(%Callable* %14, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %15, i64 1)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %15)
  call void @__quantum__rt__callable_invoke(%Callable* %15, %Tuple* %8, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %15, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %15, i64 -1)
  ret void
}

define void @Lifted__PartialApplication__1__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { double, %Array* }* }*
  %1 = getelementptr inbounds { %Array*, { double, %Array* }* }, { %Array*, { double, %Array* }* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, { double, %Array* }* }, { %Array*, { double, %Array* }* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load { double, %Array* }*, { double, %Array* }** %2, align 8
  %5 = bitcast %Tuple* %capture-tuple to { %Callable*, double }*
  %6 = getelementptr inbounds { %Callable*, double }, { %Callable*, double }* %5, i32 0, i32 1
  %7 = load double, double* %6, align 8
  %8 = getelementptr inbounds { double, %Array* }, { double, %Array* }* %4, i32 0, i32 0
  %9 = load double, double* %8, align 8
  %10 = getelementptr inbounds { double, %Array* }, { double, %Array* }* %4, i32 0, i32 1
  %11 = load %Array*, %Array** %10, align 8
  %12 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ double, double, %Array* }* getelementptr ({ double, double, %Array* }, { double, double, %Array* }* null, i32 1) to i64))
  %13 = bitcast %Tuple* %12 to { double, double, %Array* }*
  %14 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %13, i32 0, i32 0
  %15 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %13, i32 0, i32 1
  %16 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %13, i32 0, i32 2
  store double %7, double* %14, align 8
  store double %9, double* %15, align 8
  store %Array* %11, %Array** %16, align 8
  %17 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %18 = bitcast %Tuple* %17 to { %Array*, { double, double, %Array* }* }*
  %19 = getelementptr inbounds { %Array*, { double, double, %Array* }* }, { %Array*, { double, double, %Array* }* }* %18, i32 0, i32 0
  %20 = getelementptr inbounds { %Array*, { double, double, %Array* }* }, { %Array*, { double, double, %Array* }* }* %18, i32 0, i32 1
  store %Array* %3, %Array** %19, align 8
  store { double, double, %Array* }* %13, { double, double, %Array* }** %20, align 8
  %21 = getelementptr inbounds { %Callable*, double }, { %Callable*, double }* %5, i32 0, i32 0
  %22 = load %Callable*, %Callable** %21, align 8
  %23 = call %Callable* @__quantum__rt__callable_copy(%Callable* %22, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %23, i64 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %23)
  call void @__quantum__rt__callable_invoke(%Callable* %23, %Tuple* %17, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %12, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %17, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %23, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %23, i64 -1)
  ret void
}

define void @Lifted__PartialApplication__1__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { double, %Array* }* }*
  %1 = getelementptr inbounds { %Array*, { double, %Array* }* }, { %Array*, { double, %Array* }* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, { double, %Array* }* }, { %Array*, { double, %Array* }* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load { double, %Array* }*, { double, %Array* }** %2, align 8
  %5 = bitcast %Tuple* %capture-tuple to { %Callable*, double }*
  %6 = getelementptr inbounds { %Callable*, double }, { %Callable*, double }* %5, i32 0, i32 1
  %7 = load double, double* %6, align 8
  %8 = getelementptr inbounds { double, %Array* }, { double, %Array* }* %4, i32 0, i32 0
  %9 = load double, double* %8, align 8
  %10 = getelementptr inbounds { double, %Array* }, { double, %Array* }* %4, i32 0, i32 1
  %11 = load %Array*, %Array** %10, align 8
  %12 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ double, double, %Array* }* getelementptr ({ double, double, %Array* }, { double, double, %Array* }* null, i32 1) to i64))
  %13 = bitcast %Tuple* %12 to { double, double, %Array* }*
  %14 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %13, i32 0, i32 0
  %15 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %13, i32 0, i32 1
  %16 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %13, i32 0, i32 2
  store double %7, double* %14, align 8
  store double %9, double* %15, align 8
  store %Array* %11, %Array** %16, align 8
  %17 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %18 = bitcast %Tuple* %17 to { %Array*, { double, double, %Array* }* }*
  %19 = getelementptr inbounds { %Array*, { double, double, %Array* }* }, { %Array*, { double, double, %Array* }* }* %18, i32 0, i32 0
  %20 = getelementptr inbounds { %Array*, { double, double, %Array* }* }, { %Array*, { double, double, %Array* }* }* %18, i32 0, i32 1
  store %Array* %3, %Array** %19, align 8
  store { double, double, %Array* }* %13, { double, double, %Array* }** %20, align 8
  %21 = getelementptr inbounds { %Callable*, double }, { %Callable*, double }* %5, i32 0, i32 0
  %22 = load %Callable*, %Callable** %21, align 8
  %23 = call %Callable* @__quantum__rt__callable_copy(%Callable* %22, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %23, i64 1)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %23)
  call void @__quantum__rt__callable_make_controlled(%Callable* %23)
  call void @__quantum__rt__callable_invoke(%Callable* %23, %Tuple* %17, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %12, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %17, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %23, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %23, i64 -1)
  ret void
}

define void @MemoryManagement__1__RefCount(%Tuple* %capture-tuple, i64 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, double }*
  %1 = getelementptr inbounds { %Callable*, double }, { %Callable*, double }* %0, i32 0, i32 0
  %2 = load %Callable*, %Callable** %1, align 8
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %2, i64 %count-change)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %2, i64 %count-change)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %capture-tuple, i64 %count-change)
  ret void
}

define void @MemoryManagement__1__AliasCount(%Tuple* %capture-tuple, i64 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, double }*
  %1 = getelementptr inbounds { %Callable*, double }, { %Callable*, double }* %0, i32 0, i32 0
  %2 = load %Callable*, %Callable** %1, align 8
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %2, i64 %count-change)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %2, i64 %count-change)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %capture-tuple, i64 %count-change)
  ret void
}

declare void @__quantum__qis__x__body(%Qubit*)

define double @Microsoft__Quantum__Samples__PhaseEstimation__EstimatePhase__body(i64 %nGridPoints, i64 %nMeasurements, %Callable* %oracle, %Array* %eigenstate) {
entry:
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %oracle, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %oracle, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %eigenstate, i64 1)
  %0 = sub i64 %nGridPoints, 1
  %1 = sitofp i64 %0 to double
  %dPhase = fdiv double 1.000000e+00, %1
  %2 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %nGridPoints)
  %3 = sub i64 %nGridPoints, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %4 = phi i64 [ 0, %entry ], [ %8, %exiting__1 ]
  %5 = icmp sle i64 %4, %3
  br i1 %5, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %2, i64 %4)
  %7 = bitcast i8* %6 to double*
  store double 0.000000e+00, double* %7, align 8
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %8 = add i64 %4, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %phases = alloca %Array*, align 8
  store %Array* %2, %Array** %phases, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %2, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %2, i64 1)
  %9 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %nGridPoints)
  %10 = sub i64 %nGridPoints, 1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %exit__1
  %11 = phi i64 [ 0, %exit__1 ], [ %15, %exiting__2 ]
  %12 = icmp sle i64 %11, %10
  br i1 %12, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %13 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %9, i64 %11)
  %14 = bitcast i8* %13 to double*
  store double 0.000000e+00, double* %14, align 8
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %15 = add i64 %11, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  %prior = alloca %Array*, align 8
  store %Array* %9, %Array** %prior, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %9, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %9, i64 1)
  %16 = sub i64 %nGridPoints, 1
  br label %header__3

header__3:                                        ; preds = %exiting__3, %exit__2
  %idxGridPoint = phi i64 [ 0, %exit__2 ], [ %30, %exiting__3 ]
  %17 = icmp sle i64 %idxGridPoint, %16
  br i1 %17, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %18 = load %Array*, %Array** %phases, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %18, i64 -1)
  %19 = call %Array* @__quantum__rt__array_copy(%Array* %18, i1 false)
  %20 = icmp ne %Array* %18, %19
  %21 = sitofp i64 %idxGridPoint to double
  %22 = fmul double %dPhase, %21
  %23 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %19, i64 %idxGridPoint)
  %24 = bitcast i8* %23 to double*
  store double %22, double* %24, align 8
  call void @__quantum__rt__array_update_reference_count(%Array* %19, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %19, i64 1)
  store %Array* %19, %Array** %phases, align 8
  %25 = load %Array*, %Array** %prior, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %25, i64 -1)
  %26 = call %Array* @__quantum__rt__array_copy(%Array* %25, i1 false)
  %27 = icmp ne %Array* %25, %26
  %28 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %26, i64 %idxGridPoint)
  %29 = bitcast i8* %28 to double*
  store double 1.000000e+00, double* %29, align 8
  call void @__quantum__rt__array_update_reference_count(%Array* %26, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %26, i64 1)
  store %Array* %26, %Array** %prior, align 8
  call void @__quantum__rt__array_update_reference_count(%Array* %18, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %19, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %25, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %26, i64 -1)
  br label %exiting__3

exiting__3:                                       ; preds = %body__3
  %30 = add i64 %idxGridPoint, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  %31 = load %Array*, %Array** %phases, align 8
  %32 = load %Array*, %Array** %prior, align 8
  %33 = call %Array* @Microsoft__Quantum__Samples__PhaseEstimation__PointwiseProduct__body(%Array* %31, %Array* %32)
  %priorEst = call double @Microsoft__Quantum__Samples__PhaseEstimation__Integrated__body(%Array* %31, %Array* %33)
  %34 = sub i64 %nMeasurements, 1
  br label %header__4

header__4:                                        ; preds = %exiting__4, %exit__3
  %idxMeasurement = phi i64 [ 0, %exit__3 ], [ %39, %exiting__4 ]
  %35 = icmp sle i64 %idxMeasurement, %34
  br i1 %35, label %body__4, label %exit__4

body__4:                                          ; preds = %header__4
  %36 = sitofp i64 %idxMeasurement to double
  %time = call double @Microsoft__Quantum__Math__PowD__body(double 1.125000e+00, double %36)
  %inversionAngle = call double @__quantum__qis__drawrandomdouble__body(double 0.000000e+00, double 2.000000e-02)
  %sample = call %Result* @Microsoft__Quantum__Samples__PhaseEstimation__ApplyIterativePhaseEstimationStep__body(double %time, double %inversionAngle, %Callable* %oracle, %Array* %eigenstate)
  %37 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %nGridPoints)
  %38 = sub i64 %nGridPoints, 1
  br label %header__5

exiting__4:                                       ; preds = %exit__8
  %39 = add i64 %idxMeasurement, 1
  br label %header__4

exit__4:                                          ; preds = %header__4
  %40 = load %Array*, %Array** %phases, align 8
  %41 = load %Array*, %Array** %prior, align 8
  %42 = call %Array* @Microsoft__Quantum__Samples__PhaseEstimation__PointwiseProduct__body(%Array* %40, %Array* %41)
  %43 = call double @Microsoft__Quantum__Samples__PhaseEstimation__Integrated__body(%Array* %40, %Array* %42)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %oracle, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %oracle, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %eigenstate, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %40, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %41, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %2, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %9, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %33, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %42, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %40, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %41, i64 -1)
  ret double %43

header__5:                                        ; preds = %exiting__5, %body__4
  %44 = phi i64 [ 0, %body__4 ], [ %48, %exiting__5 ]
  %45 = icmp sle i64 %44, %38
  br i1 %45, label %body__5, label %exit__5

body__5:                                          ; preds = %header__5
  %46 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 %44)
  %47 = bitcast i8* %46 to double*
  store double 0.000000e+00, double* %47, align 8
  br label %exiting__5

exiting__5:                                       ; preds = %body__5
  %48 = add i64 %44, 1
  br label %header__5

exit__5:                                          ; preds = %header__5
  %likelihood = alloca %Array*, align 8
  store %Array* %37, %Array** %likelihood, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %37, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %37, i64 1)
  %49 = load %Result*, %Result** @ResultOne, align 8
  %50 = call i1 @__quantum__rt__result_equal(%Result* %sample, %Result* %49)
  br i1 %50, label %then0__1, label %else__1

then0__1:                                         ; preds = %exit__5
  %51 = load %Array*, %Array** %likelihood, align 8
  %52 = call %Range @Microsoft__Quantum__Arrays___35831c169e934b61bf2d4e6f17d0b819_IndexRange__body(%Array* %51)
  %53 = extractvalue %Range %52, 0
  %54 = extractvalue %Range %52, 1
  %55 = extractvalue %Range %52, 2
  br label %preheader__1

else__1:                                          ; preds = %exit__5
  %56 = load %Array*, %Array** %likelihood, align 8
  %57 = call %Range @Microsoft__Quantum__Arrays___35831c169e934b61bf2d4e6f17d0b819_IndexRange__body(%Array* %56)
  %58 = extractvalue %Range %57, 0
  %59 = extractvalue %Range %57, 1
  %60 = extractvalue %Range %57, 2
  br label %preheader__2

continue__1:                                      ; preds = %exit__7, %exit__6
  %61 = load %Array*, %Array** %prior, align 8
  %62 = load %Array*, %Array** %likelihood, align 8
  %unnormalizedPosterior = call %Array* @Microsoft__Quantum__Samples__PhaseEstimation__PointwiseProduct__body(%Array* %61, %Array* %62)
  call void @__quantum__rt__array_update_alias_count(%Array* %unnormalizedPosterior, i64 1)
  %63 = load %Array*, %Array** %phases, align 8
  %normalization = call double @Microsoft__Quantum__Samples__PhaseEstimation__Integrated__body(%Array* %63, %Array* %unnormalizedPosterior)
  %64 = call %Range @Microsoft__Quantum__Arrays___35831c169e934b61bf2d4e6f17d0b819_IndexRange__body(%Array* %61)
  %65 = extractvalue %Range %64, 0
  %66 = extractvalue %Range %64, 1
  %67 = extractvalue %Range %64, 2
  br label %preheader__3

preheader__1:                                     ; preds = %then0__1
  %68 = icmp sgt i64 %54, 0
  br label %header__6

header__6:                                        ; preds = %exiting__6, %preheader__1
  %idxGridPoint__1 = phi i64 [ %53, %preheader__1 ], [ %85, %exiting__6 ]
  %69 = icmp sle i64 %idxGridPoint__1, %55
  %70 = icmp sge i64 %idxGridPoint__1, %55
  %71 = select i1 %68, i1 %69, i1 %70
  br i1 %71, label %body__6, label %exit__6

body__6:                                          ; preds = %header__6
  %72 = load %Array*, %Array** %phases, align 8
  %73 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %72, i64 %idxGridPoint__1)
  %74 = bitcast i8* %73 to double*
  %75 = load double, double* %74, align 8
  %76 = fsub double %75, %inversionAngle
  %77 = fmul double %76, %time
  %arg = fdiv double %77, 2.000000e+00
  %78 = load %Array*, %Array** %likelihood, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %78, i64 -1)
  %79 = call %Array* @__quantum__rt__array_copy(%Array* %78, i1 false)
  %80 = icmp ne %Array* %78, %79
  %81 = call double @__quantum__qis__sin__body(double %arg)
  %82 = call double @Microsoft__Quantum__Math__PowD__body(double %81, double 2.000000e+00)
  %83 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %79, i64 %idxGridPoint__1)
  %84 = bitcast i8* %83 to double*
  store double %82, double* %84, align 8
  call void @__quantum__rt__array_update_reference_count(%Array* %79, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %79, i64 1)
  store %Array* %79, %Array** %likelihood, align 8
  call void @__quantum__rt__array_update_reference_count(%Array* %78, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %79, i64 -1)
  br label %exiting__6

exiting__6:                                       ; preds = %body__6
  %85 = add i64 %idxGridPoint__1, %54
  br label %header__6

exit__6:                                          ; preds = %header__6
  br label %continue__1

preheader__2:                                     ; preds = %else__1
  %86 = icmp sgt i64 %59, 0
  br label %header__7

header__7:                                        ; preds = %exiting__7, %preheader__2
  %idxGridPoint__2 = phi i64 [ %58, %preheader__2 ], [ %103, %exiting__7 ]
  %87 = icmp sle i64 %idxGridPoint__2, %60
  %88 = icmp sge i64 %idxGridPoint__2, %60
  %89 = select i1 %86, i1 %87, i1 %88
  br i1 %89, label %body__7, label %exit__7

body__7:                                          ; preds = %header__7
  %90 = load %Array*, %Array** %phases, align 8
  %91 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %90, i64 %idxGridPoint__2)
  %92 = bitcast i8* %91 to double*
  %93 = load double, double* %92, align 8
  %94 = fsub double %93, %inversionAngle
  %95 = fmul double %94, %time
  %arg__1 = fdiv double %95, 2.000000e+00
  %96 = load %Array*, %Array** %likelihood, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %96, i64 -1)
  %97 = call %Array* @__quantum__rt__array_copy(%Array* %96, i1 false)
  %98 = icmp ne %Array* %96, %97
  %99 = call double @__quantum__qis__cos__body(double %arg__1)
  %100 = call double @Microsoft__Quantum__Math__PowD__body(double %99, double 2.000000e+00)
  %101 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %97, i64 %idxGridPoint__2)
  %102 = bitcast i8* %101 to double*
  store double %100, double* %102, align 8
  call void @__quantum__rt__array_update_reference_count(%Array* %97, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %97, i64 1)
  store %Array* %97, %Array** %likelihood, align 8
  call void @__quantum__rt__array_update_reference_count(%Array* %96, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %97, i64 -1)
  br label %exiting__7

exiting__7:                                       ; preds = %body__7
  %103 = add i64 %idxGridPoint__2, %59
  br label %header__7

exit__7:                                          ; preds = %header__7
  br label %continue__1

preheader__3:                                     ; preds = %continue__1
  %104 = icmp sgt i64 %66, 0
  br label %header__8

header__8:                                        ; preds = %exiting__8, %preheader__3
  %idxGridPoint__3 = phi i64 [ %65, %preheader__3 ], [ %117, %exiting__8 ]
  %105 = icmp sle i64 %idxGridPoint__3, %67
  %106 = icmp sge i64 %idxGridPoint__3, %67
  %107 = select i1 %104, i1 %105, i1 %106
  br i1 %107, label %body__8, label %exit__8

body__8:                                          ; preds = %header__8
  %108 = load %Array*, %Array** %prior, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %108, i64 -1)
  %109 = call %Array* @__quantum__rt__array_copy(%Array* %108, i1 false)
  %110 = icmp ne %Array* %108, %109
  %111 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %unnormalizedPosterior, i64 %idxGridPoint__3)
  %112 = bitcast i8* %111 to double*
  %113 = load double, double* %112, align 8
  %114 = fdiv double %113, %normalization
  %115 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %109, i64 %idxGridPoint__3)
  %116 = bitcast i8* %115 to double*
  store double %114, double* %116, align 8
  call void @__quantum__rt__array_update_reference_count(%Array* %109, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %109, i64 1)
  store %Array* %109, %Array** %prior, align 8
  call void @__quantum__rt__array_update_reference_count(%Array* %108, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %109, i64 -1)
  br label %exiting__8

exiting__8:                                       ; preds = %body__8
  %117 = add i64 %idxGridPoint__3, %66
  br label %header__8

exit__8:                                          ; preds = %header__8
  %118 = load %Array*, %Array** %prior, align 8
  %119 = call %Array* @Microsoft__Quantum__Samples__PhaseEstimation__PointwiseProduct__body(%Array* %63, %Array* %118)
  %posteriorEst = call double @Microsoft__Quantum__Samples__PhaseEstimation__Integrated__body(%Array* %63, %Array* %119)
  call void @__quantum__rt__array_update_alias_count(%Array* %62, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %unnormalizedPosterior, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %sample, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %37, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %unnormalizedPosterior, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %119, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %62, i64 -1)
  br label %exiting__4
}

define void @Microsoft__Quantum__Intrinsic__Reset__body(%Qubit* %qubit) {
entry:
  %0 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %qubit)
  %1 = load %Result*, %Result** @ResultOne, align 8
  %2 = call i1 @__quantum__rt__result_equal(%Result* %0, %Result* %1)
  br i1 %2, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__x__body(%Qubit* %qubit)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  call void @__quantum__rt__result_update_reference_count(%Result* %0, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__body(double %eigenphase, double %time, %Array* %register) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 1)
  %0 = fmul double 2.000000e+00, %eigenphase
  %1 = fmul double %0, %time
  %2 = call %Qubit* @Microsoft__Quantum__Arrays___7cf61bc94bc0425b8a0fa4125497203a_Head__body(%Array* %register)
  call void @Microsoft__Quantum__Intrinsic__Rz__body(double %1, %Qubit* %2)
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 -1)
  ret void
}

define %Qubit* @Microsoft__Quantum__Arrays___7cf61bc94bc0425b8a0fa4125497203a_Head__body(%Array* %array) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i64 1)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %array)
  %1 = icmp sgt i64 %0, 0
  %2 = call %String* @__quantum__rt__string_create(i32 38, i8* getelementptr inbounds ([39 x i8], [39 x i8]* @2, i32 0, i32 0))
  call void @Microsoft__Quantum__Diagnostics__EqualityFactB__body(i1 %1, i1 true, %String* %2)
  %3 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 0)
  %4 = bitcast i8* %3 to %Qubit**
  %5 = load %Qubit*, %Qubit** %4, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %2, i64 -1)
  ret %Qubit* %5
}

define void @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__adj(double %eigenphase, double %time, %Array* %register) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 1)
  %0 = fmul double 2.000000e+00, %eigenphase
  %1 = fmul double %0, %time
  %2 = call %Qubit* @Microsoft__Quantum__Arrays___7cf61bc94bc0425b8a0fa4125497203a_Head__body(%Array* %register)
  call void @Microsoft__Quantum__Intrinsic__Rz__adj(double %1, %Qubit* %2)
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__adj(double %theta, %Qubit* %qubit) {
entry:
  %pauli = load i2, i2* @PauliZ, align 1
  %theta__1 = fneg double %theta
  call void @__quantum__qis__r__body(i2 %pauli, double %theta__1, %Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__ctl(%Array* %__controlQubits__, { double, double, %Array* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %0, i32 0, i32 0
  %eigenphase = load double, double* %1, align 8
  %2 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %0, i32 0, i32 1
  %time = load double, double* %2, align 8
  %3 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %0, i32 0, i32 2
  %register = load %Array*, %Array** %3, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 1)
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ double, %Qubit* }* getelementptr ({ double, %Qubit* }, { double, %Qubit* }* null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { double, %Qubit* }*
  %6 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %5, i32 0, i32 0
  %7 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %5, i32 0, i32 1
  %8 = fmul double 2.000000e+00, %eigenphase
  %9 = fmul double %8, %time
  %10 = call %Qubit* @Microsoft__Quantum__Arrays___7cf61bc94bc0425b8a0fa4125497203a_Head__body(%Array* %register)
  store double %9, double* %6, align 8
  store %Qubit* %10, %Qubit** %7, align 8
  call void @Microsoft__Quantum__Intrinsic__Rz__ctl(%Array* %__controlQubits__, { double, %Qubit* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__ctl(%Array* %__controlQubits__, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 0
  %theta = load double, double* %1, align 8
  %2 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 1
  %qubit = load %Qubit*, %Qubit** %2, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %pauli = load i2, i2* @PauliZ, align 1
  %3 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %4 = bitcast %Tuple* %3 to { i2, double, %Qubit* }*
  %5 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 0
  %6 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 1
  %7 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 2
  store i2 %pauli, i2* %5, align 1
  store double %theta, double* %6, align 8
  store %Qubit* %qubit, %Qubit** %7, align 8
  call void @__quantum__qis__r__ctl(%Array* %__controlQubits__, { i2, double, %Qubit* }* %4)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %3, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Samples__PhaseEstimation__EvolveForTime__ctladj(%Array* %__controlQubits__, { double, double, %Array* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %0, i32 0, i32 0
  %eigenphase = load double, double* %1, align 8
  %2 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %0, i32 0, i32 1
  %time = load double, double* %2, align 8
  %3 = getelementptr inbounds { double, double, %Array* }, { double, double, %Array* }* %0, i32 0, i32 2
  %register = load %Array*, %Array** %3, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 1)
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ double, %Qubit* }* getelementptr ({ double, %Qubit* }, { double, %Qubit* }* null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { double, %Qubit* }*
  %6 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %5, i32 0, i32 0
  %7 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %5, i32 0, i32 1
  %8 = fmul double 2.000000e+00, %eigenphase
  %9 = fmul double %8, %time
  %10 = call %Qubit* @Microsoft__Quantum__Arrays___7cf61bc94bc0425b8a0fa4125497203a_Head__body(%Array* %register)
  store double %9, double* %6, align 8
  store %Qubit* %10, %Qubit** %7, align 8
  call void @Microsoft__Quantum__Intrinsic__Rz__ctladj(%Array* %__controlQubits__, { double, %Qubit* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__ctladj(%Array* %__controlQubits__, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 0
  %theta = load double, double* %1, align 8
  %2 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 1
  %qubit = load %Qubit*, %Qubit** %2, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %pauli = load i2, i2* @PauliZ, align 1
  %theta__1 = fneg double %theta
  %3 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %4 = bitcast %Tuple* %3 to { i2, double, %Qubit* }*
  %5 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 0
  %6 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 1
  %7 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 2
  store i2 %pauli, i2* %5, align 1
  store double %theta__1, double* %6, align 8
  store %Qubit* %qubit, %Qubit** %7, align 8
  call void @__quantum__qis__r__ctl(%Array* %__controlQubits__, { i2, double, %Qubit* }* %4)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %3, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define double @Microsoft__Quantum__Math__PowD__body(double %x, double %y) {
entry:
  %0 = call double @llvm.pow.f64(double %x, double %y)
  ret double %0
}

declare double @__quantum__qis__drawrandomdouble__body(double, double)

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare double @__quantum__qis__sin__body(double)

declare double @__quantum__qis__cos__body(double)

define %Result* @Microsoft__Quantum__Intrinsic__Measure__body(%Array* %bases, %Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %0 = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  ret %Result* %0
}

declare %Result* @__quantum__qis__measure__body(%Array*, %Array*)

declare void @__quantum__qis__r__body(i2, double, %Qubit*)

declare void @__quantum__qis__r__ctl(%Array*, { i2, double, %Qubit* }*)

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

declare void @__quantum__qis__x__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__X__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
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

define void @Microsoft__Quantum__Intrinsic__R__body(i2 %pauli, double %theta, %Qubit* %qubit) {
entry:
  call void @__quantum__qis__r__body(i2 %pauli, double %theta, %Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__R__adj(i2 %pauli, double %theta, %Qubit* %qubit) {
entry:
  call void @__quantum__qis__r__adj(i2 %pauli, double %theta, %Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__r__adj(i2, double, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__R__ctl(%Array* %__controlQubits__, { i2, double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 0
  %pauli = load i2, i2* %1, align 1
  %2 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 1
  %theta = load double, double* %2, align 8
  %3 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 2
  %qubit = load %Qubit*, %Qubit** %3, align 8
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { i2, double, %Qubit* }*
  %6 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 0
  %7 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 1
  %8 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 2
  store i2 %pauli, i2* %6, align 1
  store double %theta, double* %7, align 8
  store %Qubit* %qubit, %Qubit** %8, align 8
  call void @__quantum__qis__r__ctl(%Array* %__controlQubits__, { i2, double, %Qubit* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__R__ctladj(%Array* %__controlQubits__, { i2, double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 0
  %pauli = load i2, i2* %1, align 1
  %2 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 1
  %theta = load double, double* %2, align 8
  %3 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 2
  %qubit = load %Qubit*, %Qubit** %3, align 8
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { i2, double, %Qubit* }*
  %6 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 0
  %7 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 1
  %8 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 2
  store i2 %pauli, i2* %6, align 1
  store double %theta, double* %7, align 8
  store %Qubit* %qubit, %Qubit** %8, align 8
  call void @__quantum__qis__r__ctladj(%Array* %__controlQubits__, { i2, double, %Qubit* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  ret void
}

declare void @__quantum__qis__r__ctladj(%Array*, { i2, double, %Qubit* }*)

define void @Microsoft__Quantum__Diagnostics__EqualityFactB__body(i1 %actual, i1 %expected, %String* %message) {
entry:
  %0 = icmp ne i1 %actual, %expected
  br i1 %0, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @Microsoft__Quantum__Diagnostics___053d3a59af6546d68d9b5cd3006abe44___QsRef3__FormattedFailure____body(i1 %actual, i1 %expected, %String* %message)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  ret void
}

define void @Microsoft__Quantum__Diagnostics___053d3a59af6546d68d9b5cd3006abe44___QsRef3__FormattedFailure____body(i1 %actual, i1 %expected, %String* %message) {
entry:
  call void @__quantum__rt__string_update_reference_count(%String* %message, i64 1)
  %0 = call %String* @__quantum__rt__string_create(i32 12, i8* getelementptr inbounds ([13 x i8], [13 x i8]* @0, i32 0, i32 0))
  %1 = call %String* @__quantum__rt__string_concatenate(%String* %message, %String* %0)
  call void @__quantum__rt__string_update_reference_count(%String* %message, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %0, i64 -1)
  %2 = call %String* @__quantum__rt__bool_to_string(i1 %expected)
  %3 = call %String* @__quantum__rt__string_concatenate(%String* %1, %String* %2)
  call void @__quantum__rt__string_update_reference_count(%String* %1, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %2, i64 -1)
  %4 = call %String* @__quantum__rt__string_create(i32 10, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @1, i32 0, i32 0))
  %5 = call %String* @__quantum__rt__string_concatenate(%String* %3, %String* %4)
  call void @__quantum__rt__string_update_reference_count(%String* %3, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %4, i64 -1)
  %6 = call %String* @__quantum__rt__bool_to_string(i1 %actual)
  %7 = call %String* @__quantum__rt__string_concatenate(%String* %5, %String* %6)
  call void @__quantum__rt__string_update_reference_count(%String* %5, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %6, i64 -1)
  call void @__quantum__rt__fail(%String* %7)
  unreachable
}

declare void @__quantum__rt__string_update_reference_count(%String*, i64)

declare %String* @__quantum__rt__string_create(i32, i8*)

declare %String* @__quantum__rt__string_concatenate(%String*, %String*)

declare %String* @__quantum__rt__bool_to_string(i1)

declare void @__quantum__rt__fail(%String*)

define double @Microsoft__Quantum__Math__Sin__body(double %theta) {
entry:
  %0 = call double @__quantum__qis__sin__body(double %theta)
  ret double %0
}

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.pow.f64(double, double) #1

define double @Microsoft__Quantum__Math__Cos__body(double %theta) {
entry:
  %0 = call double @__quantum__qis__cos__body(double %theta)
  ret double %0
}

define double @Microsoft__Quantum__Random__DrawRandomDouble__body(double %min, double %max) {
entry:
  %0 = call double @__quantum__qis__drawrandomdouble__body(double %min, double %max)
  ret double %0
}

declare void @__quantum__rt__callable_make_adjoint(%Callable*)

declare void @__quantum__rt__tuple_update_alias_count(%Tuple*, i64)

attributes #0 = { "EntryPoint" }
attributes #1 = { nounwind readnone speculatable willreturn }
