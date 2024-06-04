VxVerify aims to simplify the pre-upgrade testing of VxRail clusters by running health-checks on nodes and system VM
uploading scripts to each host and automating the analysis of the data that is returned.
VxVerify can detect, and in some cases correct or auto-fix, issues that would prevent successful VxRail upgrades.
VxVerify is written and maintained by Escalation Engineering, in order to have tests for new issues within days of them being diagnosed.

- VxVerify 2.xx.xxx is for VxRail 4.5, 4.7 & 7.0.000 (which use Python 2.7)
- VxVerify 3.xx.xxx is for VxRail 7.0.010+ & 8.0.000+ (Python 3.6)
- VxVerify 4.xx.xxx is for VxRail 8.0.210+ (Python 3.11), but VxVerify3 can also run on 8.0.210+ using Python 3.6

The VxVerify bundles of x.40.105 and above, contain packages for all supported VxRail releases.

For help with downloading, installing and running VxVerify, see KB article:
    https://www.dell.com/support/kbdoc/000021527
For details of services or settings that can be auto-corrected / restarted by VxVerify, see article:
    https://www.dell.com/support/kbdoc/000222200
For VxVerify troubleshooting, see article:
    https://www.dell.com/support/kbdoc/000066460

Note: Tests marked with a * are in draft mode (no warnings or failures
  should be returned), to be fully released at a later date.
From the x.40.105 release onwards, changes listed under each x.40 release
  will apply to both VxVerify 3 and 4, but not VxVerify2.

Recent changes:
x.40.524 (expiry date: 2024 Jun 16)
Create VxVerify minion4 for 8.0.300+ (VXV-1013)
New versions of VxVerify minion3 for ESXi 7.0.200+ will only be compiled for Python 3.8 (VXV-1013)
VxVerify minion3 for ESXi below 7.0.200, compiled on Python 3.5, will be frozen at version 3.30.503 (VXV-1013)
Add workaround for DCmanager Python libraries causing X509 errors when starting VxVerify (VXV-1014)
* Test 'privileges' has been updated to check VxRail release 7.0.510 and above (VXV-1014)

x.40.510 (expiry date: 2024 Jun 02)
VxVerify and VCFVerify code modified to address security vulnerabilities highlighted by CheckMarx (VXV-1012)

x.40.503 (expiry date: 2024 May 26)
Added 'witness' test response for 2 node clusters with external witness (VXV-1006)
Mapping VM-UUID file option, for use with VxStat, added to vxverify.sh menu (VXV-996)
VxRail cluster Deployment-type added to VxTii report (VXV-1006)
VxRail management account password checks updated (VXV-1010)
Test 'hostd' updated to check for failing localcli commands (VXV-1009)
* Test 'vibsig' has revised criteria for untrusted and unsigned VIB (VXV-1011)

2.40.503 (expiry 2025 Apr 11)
VxVerify2 is no longer being developed, so this version will not expire until 2025 (VXV-1008)
VxVerify2 updated to use the same password prompts as VxVerify3 (VXV-1008)

x.40.426 (expiry date: 2024 May 19)
Test 'lcm_state' has event added for REST API timeout (VXV-1007)
Test 'sso_admin' has new KB article for an invalid user or password (KB 224236 & VXV-1005)
Help text option added to VxVerify Shell script (VXV-1005)

x.40.419 (expiry date: 2024 May 12)
Fixed host minion results JSON file not being found for some non-vSAN nodes (VXV-1004)

x.40.412 (expiry date: 2024 May 05)
VxVerify minion critical and expiry errors will be listed for each host and will reference the log file name (VXV-1000)
Test 'pfx_vxm' cryptography updated for improved Python 3.11 compatibility (VXV-995)
Adding 'db_host' test event to give detail for DO-host errors (VXV-1000)

x.40.405 (expiry date: 2024 Apr 27)
Credentials input moved from VxVerify Shell script into Python with improved error handling (VXV-996)
Test 'sso_admin' will report failures for rejected vSphere SSO credentials, if these are supplied (VXV-996)
Shell script vxverify.sh will determine which Python to use and will contain VxVerify 2, 3 & 4 in the same bundle (VXV-966)
Test profile name, instead of the number, will be displayed when VxVerify starts (VXV-999)

x.40.322 (expiry date: 2024 Apr 14)
Test 'gpuhw' modified to only warn when GPU is present for Core upgrade profiles. The VxTii header reports GPU presence in all profiles (VXV-994)
Test 'maint_mode' updated to include the vSAN evacuation outcome prediction (VXV-753)
vSAN ESA enabled setting is added to the node VxTii report (VXV-974)
Test 'pfx_vxm' updated with cryptography for Python 3.11 compatibility (VXV-995)

x.40.315 (expiry date: 2024 Apr 07)
Test 'license_vc' added to check if internal VC has subscription based license (VXV-972)
Test 'witness' will no longer give a warning in customer upgrade profiles (VXV-992)
Test 'vmk_tag' corrected issue where 'vsanwitness' could be mistaken for 'vsan' (VXV-991)
* Test 'rcs_conn' added to trigger test connectivity if remote connectivity is enabled (VXV-971)

x.40.308 (expiry date: 2024 Mar 31)
Test 'vs_util' will not report failures for the post-upgrade test profiles (VXV-987)
Test 'qedentv' is no longer required and is being removed from the host minion (VXV-989)
VxTii report for each node will include an evacuation check listing the data to move and the objects at risk (VXV-753)
Shell script vxverify.sh determines which Python to use and contains VxVerify 2, 3 & 4 in the same bundle (VXV-966)

x.40.223 (expiry date: 2024 Mar 16)
Test 'firewall' modified to only apply to upgrades to under VxRail 8.0.200 (VXV-986)
VxVerify MD5 file formatting has been changed to match the Shell md5sum command (VXV-966)

x.40.209 (expiry date: 2024 Feb 28)
Changed vxv.log events for host tests without Paramiko, to help VCFVerify monitor the tests completed (VXV-981)
VxVerify MD5 for each PYC and SH file has been combined into a single file in the VxVerify zip - vxverify.md5 (VXV-966)

x.40.202 (expiry date: 2024 Feb 21)
Test 'vodb' modified to cope with alternative logging paths on a node, other than scratch (VXV-978)
Test 'tpm_vers' will no longer warn about TPM 1.2 being disabled after upgrading to 8.0.100+ (VXV-980)

x.40.126 (expiry date: 2024 Feb 14)
Test 'vs_util' will not include 'Storage space' for 2 node clusters in Core upgrade profiles (VXV-970)
Test 'ipmi' will check for nodes with 16 character PSNT (VXV-977)
Test 'esa_chk' will not run for clusters already running 8.0.200 and above (VXV-974)

3.40.119 (expiry date: 2024 Feb 07)
Test 'vibsig' added to look for unsigned vibs, which could cause VxRail 8.x upgrades to fail (VXV-963)
Python 3.11 code stream started for VxVerify4, which will be synchronised with VxVerify3 (VXV-975)

3.40.112 (expiry date: 2024 Jan 31)
Test 'primnodes' adjusted in VxVerify3 to only apply to stretched clusters (VXV-969)
Added test 'pw_key' to verify for zero file size of '/etc/vmware-marvin/password.key' (VXV-964)

3.40.105 (expiry date: 2024 Jan 24)
Shell script vxverify.sh will determine which Python to use and will contain VxVerify 2 & 3 in the same bundle (VXV-966)
Test 'vxm_path' removed, which has been superceeded by the multiple Python level and site-package support (VXV-965)

2.40.105 (expiry date: 2024 Feb 13)
Moving VxVerify2 into the same bundle as VxVerify3 and the vxverify.sh will determine which pyc to use (VXV-966)
Changing VxVerify2 release cadence to once per month (VXV-966)

3.31.222 (expiry date: 2024 Jan 14)
Lockdown mode status has been added to the node VxTii reports (VXV-924)
Additional failure event added when the VC datacenter name is incorrectly set as the group name (VXV-916)

x.31.215 (expiry date: 2024 Jan 07)
Python site-package importing corrected for the modified paths in VxRail 8.0.210+ (VXV-965)
Added vCenter ELM state to VxTii header, when SSO credentials are supplied (VXV-962)
Removed VxRail VC plug-in version from VxTii for 8.0.210+, where this value would be blank (VXV-772)

x.31.208 (expiry date: 2023 Dec 31)
Test 'thump' modified for 8.0.210+, to only compare the Server.crt and VxRM Server thumbprints (VXV-959)
Test 'gw_hash' modified to include VxRail 7.0.480+ and exclude 8.0.0xx (VXV-953)
Test 'sig_hash' modified to remove the warning level of alerts (VXV-956)

x.31.130 (expiry date: 2023 Dec 22)
Test 'firewall' added to check ESXi firewall rulesets for SSH and DHCP (VXV-952)
Test 'scratch' has an added read/write file check for the logging folder (VXV-951)
Fix timeout error handling for DO Cluster queries, so that the details of the timeout are logged (VXV-955)

x.31.124 (expiry date: 2023 Dec 16)
Test 'gw_hash' added to check for API gateway certificate chain using SHA1 on target code VxRail 7.0.480+ (VXV-953)
Test 'mg_user' for complex management user domain names will not apply to VxRail 8.0.200+ (VXV-954)
VxTii reports will also be saved together in HTML format as vxtii.html in modes that do not save vxverify.html (VXV-950)

x.31.117 (expiry date: 2023 Dec 09)
VxVerify and VxTii reports will be saved together in HTML format as vxverify.html (along with the usual txt files) (VXV-950)

x.31.110 (expiry date: 2023 Dec 02)
ESXi df commands will run later in the health-check sequence, to avoid timing out before testing begins (VXV-945)
Test 'primnodes' added to VxVerify3 to check that at least one node is primary (VXV-947 & VXV-529)
VxTii CPU model will be read from vim-cmd if it is not present in iDRAC HWinventory (VXV-945)

x.31.031 (expiry date: 2023 Nov 23)
Tests 'pwe_mystic' & 'pwe_root' fixed for not returning a valid result when the chage command gives unexpected results (VXV-941)
Function 'tprofile' logging corrected which incorrectly stated that the target code was not specified (VXV-942)

x.31.017 (expiry date: 2023 Nov 09)
VxTii table added for ESXi VMK interfaces and their tags (VXV-938)
Additional test for SSH client firewall ruleset will be run if ESXi cannot query iDRAC via virtual USB (VXV-940)
Test 'esx_vers' modified to highlight upgrades from under 4.7.300 needing multi-hop upgrades to 4.7.480+ (VXV-939)
Test 'scratch' modified to give specific alerts if the vmkernel log folder has no free capacity (VXV-937)

x.31.006 (expiry date: 2023 Oct 29)
Fixed issue where a host may be missing from the results table, due its SSH session not closing cleanly (VXV-932)

x.30.929 (expiry date: 2023 Oct 22)
Test 'sp_svm' modified to warn if the VxRM VM is not located on the vSAN Datastore (VXV-930)
Test 'sp_svm' modified to warn deployment type is set to Standard for HCI Mesh (VXV-931)
Test 'vsh_network' removed in VxVerify3 and replaced by 'vs_network' to health-check vSAN Network (VXV-919)
VM Tests 'iso', 'pcip' and 'vmdk_vsan' removed from test profiles 4 and 5 for VxRail 7.0+ (VXV-913)

x.30.922 (expiry date: 2023 Oct 15)
Nodes without vSAN will generate a VxTii report with an alternative drive bay table (VXV-927)
DO-host queries modified to allow for a retry and non-fatal timeouts (VXV-923)
Test 'scratch' modified follow the '/var/log/vmkernel.log' link, rather than searching for the syslog path (VXV-926)
Added retry to 'vc_api' test, which queries the VC version via the MOB (VXV-925)
Test 'df_vsan' removed for VxRail 7.0.010+, which will use 'vs_util' to health-check vSAN 'Capacity utilization' (VXV-918)
Test 'vs_network' has MTU checks (ping with large packet size), for vSAN and vMotion added (VXV-912)
Test 'vsh_cluster' removed in VxVerify3 and replaced by 'vs_cluster' to health-check vSAN 'Cluster' (VXV-919)
Test 'vsh_disk' removed in VxVerify3 and replaced by 'vs_disk' to health-check 'Physical disk' (VXV-919)

x.30.915 (expiry date: 2023 Oct 08)
Add warning for VC pyVmomi API security errors to test 'sp_svm', rather than it returning a Py_Crash (VXV-920)
Test 'vsh_util' removed in VxVerify3 and replaced by 'vs_util' to health-check vSAN 'Capacity utilization' (VXV-919)
Test 'vsh_object' removed in VxVerify3 and replaced by 'vs_object' to check vSAN object health (VXV-919)
SSH enablement via the vCenter API will double check if SSH is already enabled to avoid log confusion (VXV-903)

x.30.908 (expiry date: 2023 Oct 01)
Test 'vs_disk' added to report 'Physical disk' vSAN health-check results from the VC API (VXV-919)
Test 'vs_network' added to report 'Network' vSAN health-check results from the VC API (VXV-919)
Test 'vs_cluster' added to report 'Cluster' vSAN health-check results from the VC API (VXV-919)
Test 'vs_object' added to report 'Data' vSAN health-check results from the VC API (VXV-919)
Test 'vs_util' added to report 'Capacity utilization' vSAN health-check results from the VC API (VXV-919)
Python modules parsed and modified to reduce Python 3.11 compatibility warnings (VXPOC-2522 & VXV-908)
VM with mostly non-ascii character names will be listed as their UID instead, to avoid duplication (VXV-910)
Test 'vc_nic' updated in VxVerify2 to not test below 4.7.200 (VXV-774)
Add link to VxTii report to on-screen output (VXV-852)
Host moid added to host records, to improve cross referencing for vSAN and vMotion health results (VXV-919)
* Test 'vs_perf' added to report 'Performance service' vSAN health-check results from the VC API (VXV-919)

x.30.901 (expiry date: 2023 Sep 24)
Test 'vmotion' filtered to exclude powered off VM from giving vMotion warnings and failures (VXV-913)
Python code parsed and modified to reduce Python 3.11 compatibility warnings (VXPOC-2522 & VXV-908)
Actions for UEFI0019 and LC0100 iDRAC events added to VxTii (VXV-852)
Test 'gpu_hwi' modified to not give a failure event for upgrades to 8.0.110+ (VXV-698)
Test 'ds_pgroup' modified to handle the DVS from runtime.properties not being listed in VC MOB (VXV-908)
Test 'etc_hosts' added to check for ::1 entries in hosts file, which could cause upgrade timeouts (VXV-883)
Test 'etc_hosts' autofix added to comment out ::1 entries in hosts file, in Core upgrade profiles (VXV-883)

x.30.822 (expiry date: 2023 Sep 14)
Test 'esa_chk' added to highlight that vSAN ESA is in use in ESXi 8.0 (VXV-906)
Test 'srs_proxy' added to check SRS proxy settings for VxRail 4.7 to 7.0+ upgrades (VXV-892)
Test 'tag_sfs' updated to check for target code of 7.0.450 or higher (VXV-887)
VxVerify2 '--map' argument fixed to correctly output a VxStat UUID map file (VXV-907)
Auto-fix 'wbem_sfcdb' set to run by default if '-s' or '--service' argument not used (VXV-895)

x.30.811 (expiry date: 2023 Sep 03)
Test 'idc_hwi' modified to check for P670N nodes with both MT27800 and BCM57414 NIC (VXV-904)
VxTii LC log filters adjusted to not shorten 8 character events, such as THRM0018 (VXV-899)
Auto-fix added to 'wbem_sfcdb', which sets SFCDB-watchdog to on, in test profiles 6 & 7 (VXV-895)
Changes made to Platform Service tests to allow for path changes (VXV-900)
Change to test 'df_tmp' to prevent additional matches for similar names, such as 'dellism-tmp' (VXV-863)
Function 'cvs_get', modified to include timeouts and retries to download CVS report (VXV-881)
SSH connection failures will be dealt with earlier in VxVerify3 and will not attempt an ism_fix (VXV-905)

x.30.804 (expiry date: 2023 Aug 27)
Change in node VxTii layout to include marvin VIB version (VXV-897)
Test 'idc_swi' modified to not fail for iDRAC levels in releases 7.0.450 & 451 (VXV-894)
Test 'wbem_sfcdb' replaced test 'wbem_patch' and will apply to all recent releases (VXV-895)
Test 'wbem_sfcdb' will check that sfcbd-watchdog is set to on (VXV-895)

x.30.728 (expiry date: 2023 Aug 21)
Test 'idc_swi' modified to accept iDRAC revision '6.10.80.00' with releases 7.0.452+ (VXV-894)
The quiet parameter changed to not prevent the tests being listed in the minion txt files (VXP-72480)

x.30.721 (expiry date: 2023 Aug 14)
Additional SAS drive information added the minion JSON output, to help identify SAS4 drives (VXV-886)
LCM history report updated to include data from lcm-history.json (VXV-885)
New Python class added for containers (docker and rancher), into a single function to validate container status and services using filters (VXV-765)
Test 'scratch' modified to retry after 30 seconds if the test fails (VXV-880)

x.30.714 (expiry date: 2023 Aug 07)
Test 'rp4vm' modified to list the name of the VIB found on the nodes (VXV-884)
LC Log collection modified to account for longer message ID strings from iDRAC 6.x (VXV-880)
Test 'vcf_type' will identify VCF 5.x clusters based on their Deployment-Type, rather than the datastore (VXV-878)
Function 'cvs_get', which downloads CVS reports, updated to handle bad JSON formatting (VXV-881)

x.30.707 (expiry date: 2023 Jul 31)
The file path for rule.db downloads is fixed and the correct file should now be included in the bundle (VXV-720)
Test 'esx_vers' amended to fail for 13G nodes with a target code level over 7.0.411 (VXV-843)
Test 'scratch' modified to produce a critical result when all log lines are over 3 hours old (VXV-880)
Test 'vcf_type' will monitor for clusters with a VCF datastore, but no longer are deployed as VCF (VXV-878)

x.30.630 (expiry date: 2023 Jul 23)
Test 'op_status' added to VxV3 to detect invalid entries in the operation_status table (VXV-877)
Auto-fix added to 'op_status' to replace unrecognised operation_status table entries with 'UNKNOWN' (VXV-877)
Test 'esx_vers' amended for 13G nodes target code (VXV-843)
* Test 'compliance' added to check Continuously Validated State reports for software levels that would cause an upgrade to fail (VXV-236)

x.30.623 (expiry date: 2023 Jul 16)
Test 'flatvmdk' modified to only check target code 8.0.0x0 upgrades (VXV-838)
Test 'flatvmdk' modified to use Python localcli module rather than a 'nohup' process (VXV-838)
Test 'idc_swi' modified to identify 15G nodes with iDRAC revision '6.10.80.00' (VXV-872)
VxTii SEL output when read from Redfish will use the event 'Message', to provide more event detail (VXV-875)
Test 'mg_user' updated to check for third or more parts in management user domain names (VXV-864)
Test 'vc_trust' modified in VxVerify2 to handle missing files (VXV-867)
Test 'ifcfg' modified to check for additional and unsupported VM NIC (e.g. eth2) (VXV-860)

x.30.609 (expiry date: 2023 Jul 02)
Tests 'df_tmp' and 'df_vtrace' will now log the visorfs ramdisk information for warning or failed results (VXV-863)
Test 'vc_elm' updated to ignore found ELM for external vCenter (VXV-854)
Test 'lacp_dvs' amended to not apply to LACP on upgrades to 7.0.451 (VXV-842)
Test 'vxnode' fixed local variable error which could lead to a py_crash event (VXV-859)
Updated dell_node function updated to cope with more VxRail models, including 16G nodes (VXV-869)
DO-host query updated to find the node type, rather than querying the node during the ism_check function (VXV-868)
Test 'vc_vhc' updated to check only test from must_be_green list and expanded ix to distinguish red/yellow/other (VXV-822)

x.30.526 (expiry date: 2023 Jun 17)
Test 'lacp_dvs' added to check for LACP on upgrades to 7.0.450 (VXV-842)
Test 'vc_elm' added to check if VC's replication topology contains more than one VCSA (VXV-854)
Test 'vxnode' modified to log when vxnode.config is missing (VXV-859)
Test 'vibsx' modified to fail if RecoverPoint and/or 'emcjiraf' VIB are found on nodes with target code 8.0+ (VXV-858)
Additional cross-refencing added to cope with case inconsistencies in hostnames (VXV-857)

x.30.519 (expiry date: 2023 Jun 10)
Test 'tpm_vers' updated to warn for upgrading to 8.0.100+, which would disable TPM 1.2 (VXV-851)
Test 'esx_vers' amended to fail for 13G nodes with a target code level of 7.0.45x (VXV-843)
Test 'ds_cluster' added for heath-checking cluster connected DVS (replaced ds_rev & ds_state) (VXV-568)
Test 'rep_partnr' added for heath-checking VC Replication between partner nodes (VXV-839)
Test 'op_status' in VxVerify2 will check for NULL values in the operation_status DB table (VXV-849)
Test 'esx_vers' amended to fail for 13G nodes with a target code level of 8.0.000 (VXV-856)
Grep of RecoverPoint VIB added to vxverify.sh for Core Support profiles (VXV-847)

x.30.512 (expiry date: 2023 Jun 03)
Nodes will report RP4VM VIB version under action items (VXV-847)
Node LACP status will be listed in the VxTii report (VXV-842)
Fix for '_cluster' tests, that were missing in VxVerify2, due to JSON merging issue (VXV-848)
Test 'ifcfg' result for "eth0 should have static IP", set to warning (VXT-618)
Test 'sig_hash' added to check for weak signature algorithms on VC and ESXi 8 upgrades (VXV-844)

x.30.505 (expiry date: 2023 May 27)
Test 'flatvmdk' added to check for *flat.vmdk files in vSAN for ESXi 8.0 upgrades (VXV-838)
Test 'esx_vers' amended to fail for 13G nodes with a target code level of 7.0.450 (VXV-843)
Host tests using vSAN commands will be filtered out for nodes that do not have vSAN (VXP-69160)
Tests 'df_vtrace' & 'in_vtrace' renamed from "df_vsant" & "in_vsant" to avoid CEC conflicts (VXV-803)

x.30.428 & x.30.425 (expiry date: 2023 May 19)
Argument handling has been modified to all ADC/Radar to specify pre-upgrade test profiles (VXP-68033)
Test 'df_vtrace' added to check the free ramdisk capacity in the /vsantraces directory (VXV-803)
Test 'in_vtrace' added to check the free ramdisk inodes in the /vsantraces directory (VXV-803)

x.30.421 (expiry date: 2023 May 13)
Test 'ps_status' added to check the Platform Service health (VXV-837)
Test 'ps_restart' modified to not restart PS.Next if it is running correctly (VXV-837)
If no Platform Restart has to be done (7.0.240+ on 14G+ nodes), the minion runtime should be much quicker (VXV-837)
Test 'iplisten' modified to log more for esxcli errors, but not give a warning result (VXV-762)

x.30.414 (expiry date: 2023 May 03)
Test 'vx_cl' added to check if cluster moid corresponds to VXMs cluster membership (VXV-737)
Test 'scratch' modified to check if the local log path has been changed from /scratch/log (VXV-830)
VxVerify2 shell command function logging error fixed (VXV-831)
Test 'idc_hwi' modified to also fail for upgrades to 7.0.411 (VXV-787)

x.30.331 (expiry date: 2023 Apr 22)
Test 'mg_user' warning added if management user is within localos or VCSA SSO domain (VXV-708)
Test 'rp4vm' will warn if RP is on nodes but not in the VC extension manager (VXV-826)
DO query function logging fixed to correctly report rejected queries (VXV-827)
Added interactive mode argument ('-i', '--inter'), for use with vxverify.sh (VXV-825)
Search for RecoverPoint Splitter improved on nodes (VXV-826)
Modified VCF node check to ignore zero sized lcm-bundle-repo partitions (VXV-829)
Test 'dnslookup' added query for local manager IP to exclude this from the nslookup check (VXV-710)

x.30.322 (expiry date: 2023 Apr 13)
Fix for some host names to cause mismatches between the hostname and FQDN, causing additional host entries to be listed (VXV-823)
Test 'vodb' will check the timestamp of each checksum error and ignore those over 7 days old (VXV-760)
Test 'scratch' will check the timestamps of the latest lines to make sure it is current (VXV-519)

x.30.316 (expiry date: 2023 Apr 07)
Test 'df_service' modified the search string for '*1-service-datastore1', to pick up more formatting errors (VXV-798)
Auto-correction 'rac_fix' will run for profiles [0, 1, 2, 5, 6, 7, 8] for both VxVerify 2 & 3 (VXV-813)
Certificate verification check moved in the run order, to avoid missing credential issues (VXV-818)
Test 'sys_vm' modified to cope better with null responses from vCenter (VXV-817)
Auto-corrections will now all add entries to vxv-fix.log, including fixes done on nodes (VXV-816)
VxStat UUID to VM name mapping file will be included in the output zip file, if it is present (VXV-801)
VxTii table changed to list more VC plug-in versions, such NSX (VXV-772)

x.30.310 (expiry date: 2023 Apr 01)
Auto-fix / corrections test results will be listed in the summary table as _fixed and not a warning (VXV-750)
Pretest 'ism_check' modified to do a node type check if ISM is not running, to handle virtual nodes (VXV-725)
Test 'ssh_config' checks and corrects the SSH SHA levels for VxRail 4.7 to 7.0+ upgrades (VXV-734)
Logging of VC plug-ins changed to allow for these to be included in VxTii (VXV-772)
Tests 'df_root' & 'df_store2' enhanced to also check free inodes (VXV-811)
Mapping between hostname and FQDN improved with lookup tables added (VXV-812)
VCSA connections have added more fault tolerance and exception handling (VXV-814)
Test 'vc_api' fixed VC HA API call (VXV-806)

x.30.303 (expiry date: 2023 Mar 25)
VxVerify.sh menu updated to ask fewer questions for Core upgrade and healthcheck profiles (VXV-741)
Script vxverify.sh updated to support VxRail 8.x (VXV-807)
Test 'mapper' enhanced to add available inode checks on mapper partitions, such as /var/log (VXV-789)
Test 'mapper' fixed to avoid py_crash events (VXV-806)
Test 'ip9090' was mistakenly flagging 13G nodes as not reachable, which has been corrected (VXV-759)
Test 'idc_hwi' appended to check VxRail P670N backplane firmware (VXV-800)
The minion log data file will be read to check that it is complete, if the SSH session has completed (VXV-730)
When polling minions the vxv.log will add a suffix if one, but not all of the session, log and txt sessions are complete (VXV-730)
Test 'vc_pnid' corrected in VxVerify2 to match VxVerify3 (VXV-804)
Test 'certesx' added to more upgrade profiles check for checking the ESXi certificate on each node (VXV-663)

x.30.228 (expiry date: 2023 Mar 20)
Test 'idc_swi' fix for warnings on Dell 13G nodes (VXV-805)
Tests 'dns_node' & 'dnslookup' set to ignore false alarms for VxRail 8.0+ (VXV-710)

x.30.224 (expiry date: 2023 Mar 16)
iDRAC timeouts and retry counts from Redfish and racadm are combined to prevent the minion run-time being exceeded (VXV-797)
Test 'bmc' fixed for 13G nodes running 7.0.240+, which could return a py_crash (VXV-791)
Test 'vobd' will not return a fail if the vobd.log is readable but has no log entries (VXV-794)
Test 'vc_ntp' modified to have the same 300 second threshold for both VxVerify 2 & 3 (VXV-796)
Added retry and specific test failure for DO-host returning no results (VXV-788)
iDRAC HWinventory cross referencing improved to add data from Redfish direct queries to the XML export (VXV-783)
File transfer errors when uploading the minion will generate a new failure event (VXV-792)
Test 'idc_hwi' modified to only fail for drive firmware for upgrades to 7.0.410, 8.0.000 & 8.0.010 (VXV-787)
Rancher and docker tests are now silenced due to unexpected behaviour these test are being overhauled (VXV-764, VXV-765 & VXV-766)
VxVerify.sh menu updated to added Core upgrade and healthcheck profiles (VXV-741)
Host free capacity and inodes will be read before uploading minions or restarting iDRAC (VXV-779)

x.30.220 (expiry date: 2023 Mar 12)
Merging fixes from x.30.211 not present in x.30.217 (VXV-793)

x.30.217 (expiry date: 2023 Mar 10)
Autofix 'ism_fix' is now using ipmi to Hard/Cold reset iDrac instead of Invoke-iDRACHardReset (VXV-786)

x.30.211 (expiry date: 2023 Mar 03)
Test 'bcom5_25g' suspended pending review as to whether this setting still impacts upgrades (VXV-784)
Test 'bmc' will pause for Platform services to be fully back online for ESXi without PT agent (PT Agent based nodes already did this retry loop) (VXV-784)
VxTii drive part numbers corrected for Redfish formatting issue (VXV-785)
Test 'vc_nic' will check count of vNICs on VC (VXV-774)
Tests 'lcm_state' & 'lk_svc' added failure conditions for test profile 3 (VXV-775 & VXV-756)
Test 'pfx_vxm' added to check the VXM pfx certificate useability (VXV-709)

x.30.210 (expiry date: 2023 Mar 02)
Test 'idc_hwi' and VxTii corrected issue for missing hardware inventory system data (VXV-778)
Hardware Inventory can be read from a mixture of Redfish API, racadm and API XML export to give more complete output (VXV-738)
VxRail 7.0.200+ should have reduced minion run times, due to all racadm commands being replaced by API queries (VXV-738)
ESXi Python version will now be listed in the minion logs (VXV-731)
The minion txt and log data streams will be monitored for the last lines, so that the session can be kept open until they complete (VXV-730)
Test 'ip9090' was mistakenly flagging for 13G nodes, so this has been corrected by reading the node type from the JSON (VXV-759)

x.30.203 (expiry date: 2023 Feb 22)
VxTii and iDRAC tests moved to a hybrid of Redfish API and racadm queries (VXV-738)

x.30.130 (expiry date: 2023 Feb 19)
Modified additional checks for VxVerify3 minion completion to give more time for logs to sync (VXV-730)
Test 'idc_swi' moved from racadm to Redfish API for VxRail 7.0.200+ (VXV-738)

x.30.123 (expiry date: 2023 Feb 12)
Test 'idc_hwi' fixed for non-iDRAC based nodes to not report a test fail (VXV-755)
Minion log file search improved for hosts with overlapping names (VXV-751)

x.30.120 (expiry date: 2023 Feb 09)
Test 'idc_hwi' modified to check for SKHynix drive firmware levels (VXV-742)
Test 'tpm_vers' added to check each node's TPM version and status before upgrading to vSphere 8 (VXV-679)
Minion function fixed logging to report when no hosts are found, due to DO host errors (VXV-745)
Test 'vxm_cert' updated to not report errors for users without permissions for server.key in kubectl (VXV-743)
Auto-correction 'rac_fix' added to more profiles, which can restart iDRAC and rerun minion (VXV-597)
SEL log processing moved from racadm to Redfish API for VxRail 7.0.200+ (VXV-738)
Tests 'idc_as' & 'tls_idrac' moved from racadm to Redfish API for VxRail 7.0.200+ (VXV-738)
Secure Boot status will now be listed in each node's VxTii report, along with TPM (VXV-740)
Test 'ip9090' fixed for Dell node generation not being read correctly (VXV-747)
Test 'localos' added to all upgrade profiles (VXV-718)

x.30.113 (expiry date: 2023 Feb 02)
Example of how to use KB number added to VxVerify summary output (VXV-739)
Add Redfish API support for iDRAC queries as an alternative to remotecmd racadm (VXV-738)
ESXi minion checks should complete faster, because most of minion latency comes from the racadm commands (VXV-738)
Test 'idc_swi' updated for Redfish API and will return alternative headings in the JSON data (VXV-738)
Test 'certesx' updated to clarify failure results (VXV-663)
readme.txt renamed to readme_vxv.txt in zip bundle to avoid confusion with other documentation.

x.30.106 (expiry date: 2023 Jan 26)
Auto-correction 'rac_fix' added to restart iDRAC and related services, before rerunning minion (VXV-597)
Added additional checks for minion completion to VxVerify3 (VXV-730)
Test 'idc_swi' will return more information about any faults that are returned from iDRAC (VXV-597)
Test 'certesx' added to check the ESXi certificate on each node (VXV-663)
Test 'vxm_cert' modified to fail for an expired certificate if it is not self-signed (VXV-719)
Test 'tag_sfs' added, which reports SFS related Tags on VxRail upgrades to 8.0 (VXV-721)
Test 'localos' added to look for localos management users when upgrading to vSphere 8 (VXV-718)

... Update notes from previous releases prior to this are archived.
