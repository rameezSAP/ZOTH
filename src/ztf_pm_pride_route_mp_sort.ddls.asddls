@EndUserText.label: 'Pride: Table Function : MP Reading'
@ClientDependent: true
define table function ZTF_PM_PRIDE_ROUTE_MP_SORT
  with parameters
    @Environment.systemField: #CLIENT
    clnt : abap.clnt
//    mp   : imrc_point

returns
{
  MANDT :s_mandt;
  MDOCM :imrc_mdocm;
  POINT :imrc_point;
  IDATE :imrc_idate;
  ITIME :imrc_itime;
  ERDAT :icrdt;
  ERUHR :icrtm;
  READG :imrc_readg;
  RECDV :imrc_recdv;
  RECDU :imrc_recdu;
  CNTRR :imrc_cntrr;
  CDIFF :imrc_cdiff;
  IDIFF :imrc_idiff;


}
implemented by method
  zcl_amdb_pm_pride=>get_mp_sort;
