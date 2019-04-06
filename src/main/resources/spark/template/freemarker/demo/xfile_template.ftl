*EXP.DETAILS: ${expData['exname']!'????????'}${expData['crid']!'??'} ${expData['local_name']!}

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
${trt['trtno']?left_pad(2)} 1 1 0 ${(trt['trt_name']!)?right_pad(25)?substring(0,25)} ${(trt['cuid']!"0")?left_pad(2)} ${(trt['flid']!"0")?left_pad(2)}  0 ${(trt['icid']!"0")?left_pad(2)} ${(trt['plid']!"0")?left_pad(2)} ${(trt['irid']!"0")?left_pad(2)} ${(trt['feid']!"0")?left_pad(2)}  0  0  0  0 ${(trt['haid']!"0")?left_pad(2)} ${(trt['smid']!"0")?left_pad(2)}
</#list>
<#if cultivars?size gt 0>

*CULTIVARS
@C CR INGENO CNAME
</#if>
<#list cultivars as cultivar>
${cultivar?counter?left_pad(2)}${(expData['crid']!-99)?left_pad(3)} ${(cultivar['dssat_cul_id']!(cultivar['cul_id']!-99))?left_pad(6)} ${cultivar['cul_name']!-99}
</#list>
<#if fields?size gt 0>

*FIELDS
@L ID_FIELD WSTA....  FLSA  FLOB  FLDT  FLDD  FLDS  FLST SLTX  SLDP  ID_SOIL    FLNAME
</#if>
<#-- tier 1 -->
<#list fields as field>
${field?counter?left_pad(2)} ${(field['id_field']!-99)?right_pad(8)} ${(field['wst_id']!-99)?right_pad(8)}   -99   -99 -99     -99   -99 -99   -99    -99  ${(field['soil_id']!-99)?right_pad(10)} ${field['fl_name']!}
</#list>
<#if fields?size gt 0>
@L ...........XCRD ...........YCRD .....ELEV .............AREA .SLEN .FLWR .SLAS FLHST FHDUR
</#if>
<#-- tier 2 -->
<#list fields as field>
${field?counter?left_pad(2)}            -99             -99       -99               -99   -99   -99   -99   -99   -99
</#list>
<#if fields?size gt 0>
@L  BDWD  BDHT PMALB
</#if>
<#-- tier 3 -->
<#list fields as field>
${field?counter?left_pad(2)} ${(field['bdwd']!-99)?left_pad(5)} ${(field['bdht']!-99)?left_pad(5)} ${(field['pmalb']!-99)?left_pad(5)}
</#list> 
<#-- 

*INITIAL CONDITIONS
@C   PCR ICDAT  ICRT  ICND  ICRN  ICRE  ICWD ICRES ICREN ICREP ICRIP ICRID ICNAME
 1   -99 18079   -99   -99   -99   -99   -99   -99   -99   -99   -99   -99 -99
@C  ICBL  SH2O  SNH4  SNO3
 1    10   -99   0.7    56
 1    20   -99     0    93
-->
<#if managements.planting?size gt 0>

*PLANTING DETAILS
@P PDATE EDATE  PPOP  PPOE  PLME  PLDS  PLRS  PLRD  PLDP  PLWT  PAGE  PENV  PLPH  SPRL                        PLNAME
</#if>
<#list managements.planting as eventArr>
<#list eventArr as event>
${eventArr?counter?left_pad(2)} ${(event['date']!-99)?left_pad(5)} ${(event['edate']!-99)?left_pad(5)} ${(event['plpop']!-99)?left_pad(5)} ${(event['plpoe']!-99)?left_pad(5)} ${(event['plma']!-99)?left_pad(5)} ${(event['plds']!-99)?left_pad(5)} ${(event['plrs']!-99)?left_pad(5)} ${(event['plrd']!-99)?left_pad(5)} ${(event['pldp']!-99)?left_pad(5)} ${(event['plmwt']!-99)?left_pad(5)} ${(event['page']!-99)?left_pad(5)} ${(event['plenv']!-99)?left_pad(5)} ${(event['plph']!-99)?left_pad(5)} ${(event['plspl']!-99)?left_pad(5)}                        ${event['pl_name']!}
</#list>
</#list>
<#if managements.irrigation?size gt 0>

*IRRIGATION AND WATER MANAGEMENT
</#if>
<#list managements.irrigation as eventArr>
@I  EFIR  IDEP  ITHR  IEPT  IOFF  IAME  IAMT IRTLN IRNAME
${eventArr?counter?left_pad(2)}   -99   -99   -99   -99   -99   -99   -99     1 -99
<#if eventArr[0]?? && eventArr[0].irstr??>
@I  IRLN IRSPC IROFS IRDEP
${eventArr?counter?left_pad(2)}     1  35.6     0  35.6
@I IDATE  IROP IRVAL IRSTR IRDUR IRINT IRNUM  IRLN
<#list eventArr as event>
${eventArr?counter?left_pad(2)} ${(event['date']!-99)?left_pad(5)} ${(event['irop']!-99)?left_pad(5)} ${(event['irval']!-99)?left_pad(5)}  1:00  1380     0     1     1
</#list>
<#else>
@I IDATE  IROP IRVAL
<#list eventArr as event>
${eventArr?counter?left_pad(2)} ${(event['date']!-99)?left_pad(5)} ${(event['irop']!-99)?left_pad(5)} ${(event['irval']!-99)?left_pad(5)}
</#list>
</#if>
</#list>
<#if managements.fertilizer?size gt 0>

*FERTILIZERS (INORGANIC)
@F FDATE  FMCD  FACD  FDEP  FAMN  FAMP  FAMK  FAMC  FAMO  FOCD FERNAME
</#if>
<#list managements.fertilizer as eventArr>
<#list eventArr as event>
${eventArr?counter?left_pad(2)} ${(event['date']!-99)?left_pad(5)} ${(event['fecd']!-99)?left_pad(5)} ${(event['feacd']!-99)?left_pad(5)} ${(event['fedep']!-99)?left_pad(5)} ${(event['feamn']!-99)?left_pad(5)} ${(event['feamp']!-99)?left_pad(5)} ${(event['feamk']!-99)?left_pad(5)} ${(event['feamc']!-99)?left_pad(5)} ${(event['feamo']!-99)?left_pad(5)} ${(event['feocd']!-99)?left_pad(5)} ${event['fe_name']!}
</#list>
</#list>
 <#if managements.harvest?size gt 0>

*HARVEST DETAILS
@H HDATE  HSTG  HCOM HSIZE   HPC  HBPC HNAME
</#if>
<#list managements.harvest as eventArr>
<#list eventArr as event>
${eventArr?counter?left_pad(2)} ${(event['date']!-99)?left_pad(5)} ${(event['hastg']!-99)?left_pad(5)} ${(event['hacom']!-99)?left_pad(5)} ${(event['hasiz']!-99)?left_pad(5)} ${(event['happc']!-99)?left_pad(5)} ${(event['habpc']!-99)?left_pad(5)} ${event['ha_name']!}
</#list>
</#list>
<#if configs?size gt 0>

*SIMULATION CONTROLS
</#if>
<#list configs as config>
@N GENERAL     NYERS NREPS START SDATE RSEED SNAME.................... SMODEL
${config?counter?left_pad(2)} GE              1     1     S ${(config.general.sdate!-99)?left_pad(5)}  2150 DEFAULT SIMULATION CONTRL 
@N OPTIONS     WATER NITRO SYMBI PHOSP POTAS DISES  CHEM  TILL   CO2
${config?counter?left_pad(2)} OP          ${(config.options.water!"Y")?left_pad(5)} ${(config.options.nitro!"Y")?left_pad(5)}     Y     N     N     N     N     N     M
@N METHODS     WTHER INCON LIGHT EVAPO INFIL PHOTO HYDRO NSWIT MESOM MESEV MESOL
${config?counter?left_pad(2)} ME              M     M     E     R     N     C     G     1     G     S     2
@N MANAGEMENT  PLANT IRRIG FERTI RESID HARVS
${config?counter?left_pad(2)} MA              R     R     R     R ${(config.management.harvs!"M")?left_pad(5)}
@N OUTPUTS     FNAME OVVEW SUMRY FROPT GROUT CAOUT WAOUT NIOUT MIOUT DIOUT VBOSE CHOUT OPOUT
${config?counter?left_pad(2)} OU              N     Y     Y     1     Y     Y     Y     Y     N     N     D     N     N

@  AUTOMATIC MANAGEMENT
@N PLANTING    PFRST PLAST PH2OL PH2OU PH2OD PSTMX PSTMN
${config?counter?left_pad(2)} PL          82050 82064    40   100    30    40    10
@N IRRIGATION  IMDEP ITHRL ITHRU IROFF IMETH IRAMT IREFF
${config?counter?left_pad(2)} IR             30    50   100 GS000 IR001    10  1.00
@N NITROGEN    NMDEP NMTHR NAMNT NCODE NAOFF
${config?counter?left_pad(2)} NI             30    50    25 FE001 GS000
@N RESIDUES    RIPCN RTIME RIDEP
${config?counter?left_pad(2)} RE            100     1    20
@N HARVEST     HFRST HLAST HPCNP HPCNR
${config?counter?left_pad(2)} HA              0 83057   100     0
 
 </#list>