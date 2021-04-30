      module DEMmap_m

      use, intrinsic :: iso_fortran_env, only : OUTPUT_UNIT

      use DEMglobals_m
      use DEMprojections_m
      use DEMtile_m

      implicit none

      type :: DEMmap_t
          character(len=80) :: gridname
          INTEGER :: nx, ny
          INTEGER :: itrans
          INTEGER :: ntiles_x, ntiles_y
          INTEGER :: tilesize_x, tilesize_y
          DOUBLE PRECISION :: offx, modx
          DOUBLE PRECISION :: offy, mody
          DOUBLE PRECISION :: offz, sclz
          DOUBLE PRECISION :: rottrans(3,3)
          INTEGER :: iproj, nproj
          DOUBLE PRECISION, allocatable :: projparm(:)
          DOUBLE PRECISION :: eps_xy, eps_z
          INTEGER :: ntest
          DOUBLE PRECISION, allocatable :: testxyz(:,:)
          DOUBLE PRECISION :: val_nan, thr_nan
          DOUBLE PRECISION :: xmin, xmax, ymin, ymax
          DOUBLE PRECISION, allocatable :: vecx(:), vecy(:)
          DOUBLE PRECISION :: step_x, step_y
          TYPE(DEMtile_t), allocatable :: tiles(:,:)
      end type


      contains


      subroutine DEMmap_load(DEMmap, filename)
          type(DEMmap_t), intent(out) :: DEMmap
          character(len=*), intent(in) :: filename

          INTEGER :: iunit
          INTEGER(OFFSET_K) :: grid_offset
          INTEGER :: nx_tile, ny_tile
          INTEGER :: i, ix, iy, itrans, iproj
          double precision :: ztest
          iunit=57

!!!!      open(newunit=iunit, file=trim(filename), status='old', &
          open(unit=iunit, file=trim(filename), status='old', &
                  form='unformatted', access='stream', action='read')

          ! Name grid: gridname

          inquire(unit=iunit,pos=i)
          write(*,*) 'pos=',i

          read(iunit) DEMmap%gridname
          write(*,*) ' Grid description : '
          write(*,*) DEMmap%gridname

          inquire(unit=iunit,pos=i)
          write(*,*) 'pos=',i

          ! Dimension of grid: nx, ny
          read(iunit) DEMmap%nx
          read(iunit) DEMmap%ny
          write(*,*) ' grid dimensions : ', &
                  DEMmap%nx,' x ',DEMmap%ny

          ! Size of tiles in each dimension
          read(iunit) DEMmap%tilesize_x
          read(iunit) DEMmap%tilesize_y

          ! Set the number of tiles in each dimension
          DEMmap%ntiles_x = DEMmap%nx / DEMmap%tilesize_x
          if (MOD(DEMmap%nx, DEMmap%tilesize_x) /= 0) then
              DEMmap%ntiles_x = DEMmap%ntiles_x + 1
          end if
          DEMmap%ntiles_y = DEMmap%ny / DEMmap%tilesize_y
          if (MOD(DEMmap%ny, DEMmap%tilesize_y) /= 0) then
              DEMmap%ntiles_y = DEMmap%ntiles_y + 1
          end if

          ! scale/offset of grid: sclz, offz
          read(iunit) DEMmap%sclz
          read(iunit) DEMmap%offz
          write(*,*) ' grid scale/offset : ', &
                  DEMmap%sclz,DEMmap%offz

          ! coordinate transformation type
          !   0 = none
          !   1 = expect [offx, modx, offy, mody]
          !   2 = expect rotation matrix
          read(iunit) itrans
          DEMmap%itrans=itrans
          write(*,*) 'Coordinate transformation: ',DEMmap%itrans

          select case(DEMmap%itrans)
          case(COORDTRANSFORM_NONE)

          case(COORDTRANSFORM_OFFSET)
              ! coordinate transformation: offx, modx, offy, mody
              !  offx/offy is added to DLA/PHI, respectively
              !  if modx or mody != 0, then modulo is applied after
              !                             offx/offy is added
              read(iunit) DEMmap%offx, DEMmap%modx
              read(iunit) DEMmap%offy, DEMmap%mody
              write(*,*) ' X coordinate transformation: ', &
                      DEMmap%offx, DEMmap%modx
              write(*,*) ' Y coordinate transformation: ', &
                      DEMmap%offy, DEMmap%mody

          case(COORDTRANSFORM_ROTATION_MATRIX)
              ! coordinate transformation: rotation matrix
              !  this is the matrix to transform from GEODYN PBF to
              !  the GRID-DEM frame
              read(iunit) DEMmap%rottrans(1,1:3)
              read(iunit) DEMmap%rottrans(2,1:3)
              read(iunit) DEMmap%rottrans(3,1:3)
              write(*,*) '   coordinate transformation matrix : '
              do i = 1, 3
                  write(*,"(' | ',3(D20.13,1x),'| ')") &
                              DEMmap%rottrans(i,1:3)
              end do
          end select

          ! ID of projection and number of projection
          ! parameters: iproj, nproj
          read(iunit) iproj
          DEMmap%iproj=iproj
          write(*,*) ' projection = ',projname(DEMmap%iproj)
          if (DEMmap%iproj .gt. iprojmax) then
              write(*,*) 'ERROR: projection type cannot be > ',iprojmax
              stop 16
          end if
          read(iunit) DEMmap%nproj
          ! check if that matches projection information in DEMglobals
          if (DEMmap%nproj .ne. nprojreq(DEMmap%iproj)) then
              write(*,*) 'ERROR: expecting ', &
                      nprojreq(DEMmap%iproj), &
                      ' parameters, not ', DEMmap%nproj
              stop 16
          end if

          ! projection parameters: projparm[nproj]
          if (DEMmap%nproj.gt.1) then
              allocate(DEMmap%projparm(DEMmap%nproj))
              read(iunit) DEMmap%projparm
          end if
          ! tolerance for checking grid points: eps_xy, eps_dz
          read(iunit) DEMmap%eps_xy, DEMmap%eps_z
          write(*,*) 'Tolerances for sanity checks: ', &
                  DEMmap%eps_xy, DEMmap%eps_z

          ! number of test points: ntest, testxyz[ntest,3]
          read(iunit) DEMmap%ntest
          write(*,*) ' number of test points = ',DEMmap%ntest
          allocate(DEMmap%testxyz(DEMmap%ntest,3))
          do i=1,DEMmap%ntest
              read(iunit) DEMmap%testxyz(i,1:3)
              write(*,*) 'test point: ',DEMmap%testxyz(i,1:3)
          end do

          ! value of NaN, threshold for NaN output: val_nan, thr_nan
          read(iunit) DEMmap%val_nan, DEMmap%thr_nan
          write(*,*) ' NaN val/thr = ',DEMmap%val_nan, &
                                       DEMmap%thr_nan

          ! box of permitted use of current DEM: xmin, xmax, ymin,
          !                                    ymax (in projected space)
          read(iunit) DEMmap%xmin, DEMmap%xmax, &
                  DEMmap%ymin, DEMmap%ymax
          write(*,*) ' Box of use = ',DEMmap%xmin, &
            DEMmap%xmax, DEMmap%ymin, DEMmap%ymax

          ! vector in X: vecx[nx]
          write(*,*) ' reading vecx ...'
          allocate(DEMmap%vecx(DEMmap%nx))
          read(iunit) DEMmap%vecx
          ! vector in Y: vecy[ny]
          write(*,*) ' reading vecy ...'
          allocate(DEMmap%vecy(DEMmap%ny))
          read(iunit) DEMmap%vecy
          ! planetary radii in meters: grid[ny,nx]
          write(*,*) ' reading grid ...'

          ! Initialize the tiles
          inquire(unit=iunit, pos=grid_offset)
          allocate(DEMmap%tiles(DEMmap%ntiles_y,DEMmap%ntiles_x))
          write(*,*) '  [ ',DEMmap%ntiles_y,' x ',DEMmap%ntiles_x,' ] '
          do ix = 1, DEMmap%ntiles_x
              nx_tile = MIN(DEMmap%tilesize_x, &
                      DEMmap%nx-(ix-1)*DEMmap%tilesize_x)
              do iy = 1, DEMmap%ntiles_y
                  ny_tile = MIN(DEMmap%tilesize_y, &
                          DEMmap%ny-(iy-1)*DEMmap%tilesize_y)
                  call DEMtile_init(DEMmap%tiles(iy,ix), filename, &
                          grid_offset, nx_tile, ny_tile)
                  grid_offset = grid_offset + nx_tile * ny_tile * 8
              end do
          end do

          close(iunit)

          ! check X and Y values
          DEMmap%step_x = (DEMmap%vecx(DEMmap%nx) &
                  - DEMmap%vecx(1)) / (DEMmap%nx-1)
          do ix = 1, DEMmap%nx
              if (ABS(DEMmap%vecx(ix)-(DEMmap%vecx(1)+ &
                      DEMmap%step_x*(ix-1))) &
                      > DEMmap%eps_xy) then
                  write(*,*) DEMmap%vecx(1), (DEMmap%vecx(1)+ &
                          DEMmap%step_x*(ix-1)), &
                          DEMmap%vecx(ix)
                  write(*,'(3D25.10)') DEMmap%vecx(1), &
                          DEMmap%vecx(ix), DEMmap%step_x
                  write(*,'(I0,D25.10)') ix,(DEMmap%vecx(1)+ &
                          DEMmap%step_x*(ix-1))
                  flush(OUTPUT_UNIT)
                  write(*,'(2A)') "ERROR: Longitude values in input ", &
                          "DEM don't match expected values."
                  stop 16
              end if
              DEMmap%vecx(ix) = DEMmap%vecx(1) + &
                      DEMmap%step_x*(ix-1)
          end do

          DEMmap%step_y = (DEMmap%vecy(DEMmap%ny) &
                  - DEMmap%vecy(1)) / (DEMmap%ny-1)
          do iy = 1, DEMmap%ny
              if (ABS(DEMmap%vecy(iy)-(DEMmap%vecy(1)+ &
                      DEMmap%step_y*(iy-1))) &
                      > DEMmap%eps_xy) then
                  write(*,*) DEMmap%vecy(1), (DEMmap%vecy(1)+ &
                          DEMmap%step_y*(iy-1)), &
                          DEMmap%vecy(iy)
                  write(*,'(3D25.10)') DEMmap%vecy(1), &
                          DEMmap%vecy(iy), DEMmap%step_y
                  write(*,'(I0,D25.10)') iy,(DEMmap%vecy(1)+ &
                          DEMmap%step_y*(iy-1))
                  flush(OUTPUT_UNIT)
                  write(*,'(2A)') "ERROR: Longitude values in input ", &
                          "DEM don't match expected values."
                  stop 16
              end if
              DEMmap%vecy(iy) = DEMmap%vecy(1) + &
                      DEMmap%step_y*(iy-1)
          end do

          write(*,*) 'STEPS GRID : ', DEMmap%step_x, &
                  DEMmap%step_y

          ! check the TEST points, if any (and STOP if no agreement
          ! is found) interpolate using this same routine (recursive)
          DEMmap%itrans=0
          DEMmap%iproj=1
          do i=1,DEMmap%ntest
!             write(*,*) '  test point ',i
              ztest=DEMmap_interpolate(DEMmap, DEMmap%testxyz(i,1), &
                      DEMmap%testxyz(i,2))
              write(*,*) '  test point ',i,' : x/y/z = '
              write(*,*) DEMmap%testxyz(i,1:3)
              write(*,*) '  interpolation gave zint=',ztest
              write(*,*) '   difference = ', &
                     ABS(ztest-DEMmap%testxyz(i,3))
              if (ABS(ztest-DEMmap%testxyz(i,3)) &
                          > DEMmap%eps_z) then
                  write(*,*) 'ERROR: test point does not check out !'
                  write(*,*) 'DIFF IS GREATER THAN ',DEMmap%eps_z,' !!'
                  stop 16
              end if
          end do
          DEMmap%itrans=itrans
          DEMmap%iproj=iproj
      end subroutine


      function DEMmap_interpolate(DEMmap, DLA, PHI) result(VALINT)
          double precision :: VALINT
          type(DEMmap_t), intent(inout) :: DEMmap
          double precision, intent(in) :: PHI ! latitude (degrees)
          double precision, intent(in) :: DLA ! longitude (degrees)

          INTEGER :: ix, iy
          DOUBLE PRECISION :: DLA2, PHI2, val_nan
          DOUBLE PRECISION :: DLAtmp, PHItmp, ttmp, utmp
          DOUBLE PRECISION :: xc, yc, zc, rc, xc2, yc2, zc2
          DOUBLE PRECISION :: q11, q12, q21, q22, x1, y1, x, y

!         write(*,*) DEMmap%itrans

          select case(DEMmap%itrans)
          case(COORDTRANSFORM_NONE)
              DLA2=DLA
              PHI2=PHI
          case(COORDTRANSFORM_OFFSET)
              DLA2=DLA+DEMmap%offx
              if (DEMmap%modx > 0) then
                  DLA2=MOD(DLA2,DEMmap%modx)
              end if
              PHI2=PHI+DEMmap%offy
              if (DEMmap%mody > 0) then
                  PHI2=MOD(PHI2,DEMmap%mody)
              end if
          case(COORDTRANSFORM_ROTATION_MATRIX)
              rc=1.0D0
              call spherical_to_cartesian(DLA,PHI,rc,xc,yc,zc)
              xc2=DEMmap%rottrans(1,1)*xc+ &
                  DEMmap%rottrans(1,2)*yc+ &
                  DEMmap%rottrans(1,3)*zc
              yc2=DEMmap%rottrans(2,1)*xc+ &
                  DEMmap%rottrans(2,2)*yc+ &
                  DEMmap%rottrans(2,3)*zc
              zc2=DEMmap%rottrans(3,1)*xc+ &
                  DEMmap%rottrans(3,2)*yc+ &
                  DEMmap%rottrans(3,3)*zc
              call cartesian_to_spherical(xc2,yc2,zc2,DLA2,PHI2,rc)
          end select

          val_nan=DEMmap%val_nan
          ! project
          select case(DEMmap%iproj)
          case(PROJTYPE_CYLINDRICAL)
              DLAtmp=DLA2
              PHItmp=PHI2
          case(PROJTYPE_STEREOGRAPHIC)
              call project_stereographic(DLA2, PHI2, &
                      DEMmap%projparm(1), DEMmap%projparm(2), &
                      DEMmap%projparm(3), DLAtmp, PHItmp)
          case(PROJTYPE_GNOMONIC)
              call project_gnomonic(DLA2, PHI2, DEMmap%projparm(1), &
                      DEMmap%projparm(2), DEMmap%projparm(3), &
                      DLAtmp, PHItmp)
          case(PROJTYPE_LAMBERT_CONFORMAL_CONIC)
              call project_lambertconformalconic(DLA2, PHI2, &
                      DEMmap%projparm(1), DEMmap%projparm(2), &
                      DEMmap%projparm(3), DEMmap%projparm(4), &
                      DEMmap%projparm(5), DEMmap%projparm(6), &
                      DEMmap%projparm(7), DEMmap%projparm(8), &
                      DEMmap%projparm(9), DLAtmp, PHItmp)
          end select

          ! use bilinear interpolation to get VALINT
          ix = INT((DLAtmp - DEMmap%vecx(1)) / DEMmap%step_x) + 1
          iy = INT((PHItmp - DEMmap%vecy(1)) / DEMmap%step_y) + 1

          ! check if within allowed bounds of grid
          if (DLAtmp < DEMmap%xmin) ix=0
          if (DLAtmp > DEMmap%xmax) ix=DEMmap%nx+1
          if (PHItmp < DEMmap%ymin) iy=0
          if (PHItmp > DEMmap%ymax) iy=DEMmap%ny+1

!         write(*,*) 'A: ',DLAtmp, PHItmp
!         write(*,*) 'B: ',DEMmap%xmin,DEMmap%xmax
!         write(*,*) 'C: ',DEMmap%ymin,DEMmap%ymax
!         write(*,*) 'D: ',ix,iy

          if (ix > 0 .and. ix <= DEMmap%nx &
                  .and. iy > 0 .and. iy <= DEMmap%ny) then
              x = DLAtmp
              y = PHItmp
              x1 = DEMmap%vecx(ix)
              y1 = DEMmap%vecy(iy)
!               write(*,*) x,y,x1,y1
              q11 = DEMmap_getvalue(DEMmap, ix, iy)
              q12 = DEMmap_getvalue(DEMmap, ix+1, iy)
              q21 = DEMmap_getvalue(DEMmap, ix, iy+1)
              q22 = DEMmap_getvalue(DEMmap, ix+1, iy+1)
!             write(*,*) 'values: ',q11,q12,q21,q22

              if ( q11==val_nan .or. q12==val_nan .or. &
                          q21==val_nan .or. q22==val_nan ) then
                  VALINT=INTERP_NAN
              else
                  ttmp=(x-x1)/DEMmap%step_x
                  utmp=(y-y1)/DEMmap%step_y
                  VALINT=(1-ttmp)*(1-utmp)*q11+ttmp*(1-utmp)*q12 &
                        + ttmp*utmp*q21 &
                        + (1-ttmp)*utmp*q22
              endif

              if (debug_level > 0) then
                  write(*,'(A,5(1x,D20.13))') 'INTERP: ', DLA, &
                          PHI, DLAtmp, PHItmp, VALINT
              end if

              ! revert to NaN value if above threshold
              !     if (VALINT*sign(1.0d0,DEMmap%val_nan) .gt. &
              !           abs(DEMmap%thr_nan)) VALINT = 999999.0d0
          else
              VALINT = INTERP_NAN
          end if
      end function


      function DEMmap_getvalue(DEMmap, ix, iy)
          double precision :: DEMmap_getvalue
          type(DEMmap_t), intent(inout) :: DEMmap
          INTEGER, intent(in) :: ix, iy

          INTEGER :: itile_x, itile_y, itx, ity

          ! Get coordinates of the relevant tile
          itile_x = (ix-1) / DEMmap%tilesize_x + 1
          itile_y = (iy-1) / DEMmap%tilesize_y + 1

          ! Get coordinates of the point within the tile
          itx = ix - (itile_x-1) * DEMmap%tilesize_x
          ity = iy - (itile_y-1) * DEMmap%tilesize_y

       DEMmap_getvalue=DEMtile_getvalue(DEMmap%tiles(itile_y,itile_x),&
     &            itx, ity) * DEMmap%sclz + DEMmap%offz
      end function


      end module