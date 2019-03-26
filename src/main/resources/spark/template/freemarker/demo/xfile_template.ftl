*EXP.DETAILS: ${expData['exname']!'????????'}${expData['crid_dssat']!'??'} ${expData['local_name']!}

*GENERAL
<#if expData['people']??>
@PEOPLE
 ${expData['people']}
 
</#if>
<#if expData['address']??>
@ADDRESS
 ${expData['address']}
 
</#if>
<#if expData['site_name']??>
@SITE
 ${expData['site_name']}
 
</#if>
<#if expData['exp_narr']??>
@NOTES
 ${expData['exp_narr']} 
</#if>

*TREATMENTS                        -------------FACTOR LEVELS------------
@N R O C TNAME.................... CU FL SA IC MP MI MF MR MC MT ME MH SM
<#list treatments as trt>
${trt['trtno']?left_pad(2)} 1 1 0 ${(trt['trt_name']!)?right_pad(25)?substring(0,25)}  0 ${(trt['fid']!"0")?left_pad(2)}  0  0  0  0  0  0  0  0  0  0  0
</#list>

*CULTIVARS
@C CR INGENO CNAME
 1 TM DRI319 -99

*FIELDS
<#list fields as field>
@L ID_FIELD WSTA....  FLSA  FLOB  FLDT  FLDD  FLDS  FLST SLTX  SLDP  ID_SOIL     BDWD  BDHT PMALB FLNAME
${field?counter?left_pad(2)} ${field['id_field']?right_pad(8)} ${field['wst_id']?right_pad(8)}   -99   -99 -99     -99   -99 -99   -99    -99  ${field['soil_id']?right_pad(10)}   -99   -99   -99 ${field['fl_name']!}
@L ...........XCRD ...........YCRD .....ELEV .............AREA .SLEN .FLWR .SLAS FLHST FHDUR
${field?counter?left_pad(2)}            -99             -99       -99               -99   -99   -99   -99   -99   -99
</#list>
 
*INITIAL CONDITIONS
@C   PCR ICDAT  ICRT  ICND  ICRN  ICRE  ICWD ICRES ICREN ICREP ICRIP ICRID ICNAME
 1   -99 18079   -99   -99   -99   -99   -99   -99   -99   -99   -99   -99 -99
@C  ICBL  SH2O  SNH4  SNO3
 1    10   -99   0.7    56
 1    20   -99     0    93

*PLANTING DETAILS
@P PDATE EDATE  PPOP  PPOE  PLME  PLDS  PLRS  PLRD  PLDP  PLWT  PAGE  PENV  PLPH  SPRL                        PLNAME
 1 18095   -99   1.6   1.6     T     R   203    90  1.02   2.2  27.5  20.1   -99   -99                        -99

*IRRIGATION AND WATER MANAGEMENT
@I  EFIR  IDEP  ITHR  IEPT  IOFF  IAME  IAMT IRTLN IRNAME
 1   -99   -99   -99   -99   -99   -99   -99     1 -99
@I  IRLN IRSPC IROFS IRDEP
 1     1  35.6     0  35.6
@I IDATE  IROP IRVAL IRSTR IRDUR IRINT IRNUM  IRLN
 1 18095 IR005  0.08  1:00  1380     0     1     1

*FERTILIZERS (INORGANIC)
@F FDATE  FMCD  FACD  FDEP  FAMN  FAMP  FAMK  FAMC  FAMO  FOCD FERNAME
 1 18122 FE001 AP005  35.6  23.9   -99   -99   -99   -99   -99 -99
 1 18129 FE001 AP005  35.6  23.9   -99   -99   -99   -99   -99 -99
 1 18134 FE001 AP005  35.6  23.9   -99   -99   -99   -99   -99 -99
 1 18141 FE001 AP005  35.6  23.9   -99   -99   -99   -99   -99 -99
 1 18150 FE001 AP005  35.6  23.9   -99   -99   -99   -99   -99 -99
 1 18155 FE001 AP005  35.6  23.9   -99   -99   -99   -99   -99 -99
 1 18165 FE001 AP005  35.6  23.9   -99   -99   -99   -99   -99 -99
 1 18170 FE001 AP005  35.6  23.9   -99   -99   -99   -99   -99 -99

*HARVEST DETAILS
@H HDATE  HSTG  HCOM HSIZE   HPC  HBPC HNAME
 1 18225 -99   -99   -99     -99   -99 -99

*SIMULATION CONTROLS
@N GENERAL     NYERS NREPS START SDATE RSEED SNAME.................... SMODEL
 1 GE              1     1     S 18079  2150 DEFAULT SIMULATION CONTRL 
@N OPTIONS     WATER NITRO SYMBI PHOSP POTAS DISES  CHEM  TILL   CO2
 1 OP              Y     Y     Y     N     N     N     N     N     M
@N METHODS     WTHER INCON LIGHT EVAPO INFIL PHOTO HYDRO NSWIT MESOM MESEV MESOL
 1 ME              M     M     E     R     N     C     G     1     G     S     2
@N MANAGEMENT  PLANT IRRIG FERTI RESID HARVS
 1 MA              R     R     R     R     R
@N OUTPUTS     FNAME OVVEW SUMRY FROPT GROUT CAOUT WAOUT NIOUT MIOUT DIOUT VBOSE CHOUT OPOUT
 1 OU              N     Y     Y     1     Y     Y     Y     Y     N     N     D     N     N

@  AUTOMATIC MANAGEMENT
@N PLANTING    PFRST PLAST PH2OL PH2OU PH2OD PSTMX PSTMN
 1 PL          82050 82064    40   100    30    40    10
@N IRRIGATION  IMDEP ITHRL ITHRU IROFF IMETH IRAMT IREFF
 1 IR             30    50   100 GS000 IR001    10  1.00
@N NITROGEN    NMDEP NMTHR NAMNT NCODE NAOFF
 1 NI             30    50    25 FE001 GS000
@N RESIDUES    RIPCN RTIME RIDEP
 1 RE            100     1    20
@N HARVEST     HFRST HLAST HPCNP HPCNR
 1 HA              0 83057   100     0