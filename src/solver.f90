
subroutine solver(mesh)
  use util
  implicit none
  type(meshdef) :: mesh

  call LU(ndof*mesh%nnode, mesh%A, mesh%B, mesh%X)
  call residual(ndof*mesh%nnode, mesh%A, mesh%B, mesh%X)
end subroutine solver

subroutine LU(nndof, Ain, B, X)
  use util
  implicit none
  integer(kint) :: i, j, k, nndof
  real(kdouble) :: Ain(nndof, nndof), B(nndof), X(nndof)
  real(kdouble), allocatable :: A(:,:)
  real(kdouble) :: t

  allocate(A(nndof, nndof))
  do i=1, nndof
    do j=1, nndof
      A(j,i) = Ain(j,i)
    enddo
  enddo

  do i=1, nndof
    A(i,i) = 1.0d0/A(i,i)
    do j=i+1, nndof
      A(i,j) = A(i,j) * A(i,i)
      do k=i+1, nndof
        A(k,j) = A(k,j) - A(i,j) * A(k,i)
      enddo
    enddo
  enddo

  X = B

  do i=1,nndof
    t = 0.0d0
    do j=1,i-1
      t = t + A(j,i) * X(j)
    enddo
    X(i) = X(i) - t
  enddo

  do i=nndof, 1, -1
    t = 0.0d0
    do j=nndof, i+1, -1
      t = t + A(j,i) * X(j)
    enddo
    X(i) = X(i) - t
    X(i) = X(i) * A(i,i)
  enddo

  deallocate(A)
end subroutine LU

subroutine residual(nndof, A, B, X)
  use util
  implicit none
  integer(kint) :: i, j, nndof
  real(kdouble) :: A(nndof, nndof), B(nndof), X(nndof), res, tmp
  real(kdouble), allocatable :: Y(:)

  allocate(Y(nndof))

  do i=1, nndof
    Y(i) = 0.0d0
    do j=1, nndof
      Y(i) = Y(i) + A(j,i) * X(j)
    enddo
  enddo

  res = 0.0d0
  do i=1, nndof
    tmp = B(i) - Y(i)
    res = res + tmp * tmp
  enddo
  res = dsqrt(res)

  write(*,"(a, 1pe12.5)")"  ** solver residual: ", res

  deallocate(Y)
end subroutine residual
