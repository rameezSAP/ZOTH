@EndUserText.label: 'Pride : MP Count'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZC_PM_PRIDE_MP_COUNT
  as select from zpm_pride_hier_m
{
  key route_id                 as RouteId,
//  key func_loc                 as FuncLoc,
  key equipment                as Equipment,
//      sum( case when active = 'X' and value > 0 then 0
//                when active = 'R' and value > 0 then 0
//                when active = 'E'  then 0
//                when active = 'O'  then 0
//                  else 1 end ) as remaining_count
                  
      cast( sum( case when active = 'X' and value_char != '' then 0
                when active = 'R' and value_char != '' then 0
                when active = 'E'  then 0
                when active = 'O'  then 0
                  else 1 end ) as abap.dec( 4, 0 )  ) as remaining_count                  
}
group by
  route_id,
//  func_loc,
  equipment
