      program model
      implicit none
      integer indic, n, nn
      parameter (nn=7)
      double precision f,x(nn),g(nn)
      integer izs(1)
      real    rzs(1)
      double precision dzs(1)

      integer io, i
      character*(80) fmt

      io = 99
      open(io,file='model_in',status='old',form='unformatted')
      read(io) indic,n
      if ( n.gt.nn ) stop 'n > nn'
      read(io) (x(i),i=1,n)
      read(io) izs,rzs,dzs
      close(io)
      do i=1,n
       g(i)=0.
      enddo
      call mysimul(indic,n,f,x,g,izs,rzs,dzs)
      write(fmt,'(A,I4,A)') '(A,',n+1,'E12.4)'
      write(*,fmt) 'model finished f    = ', f, (g(i),i=1,n)
      io = 99
      open(io,file='model_out',status='unknown',form='unformatted')
      write(io) indic,n
      write(io) f
      write(io) (g(i),i=1,n)
      write(io) izs,rzs,dzs
      close(io)
      end
