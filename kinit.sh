kinit() { 
        ######################### 
        # This function changing the default KRB5 ticket cache file to be depend on user name and principal name (instead of UID).
        # You can run this function with '--normal' argument to prevent changing the KRB5 ticket cache file. 
        # 
        # Developed by Ulis Ilya 
        # mailto:ilyaul@matrixbi.co.il 
        ######################### 
        
        os_kinit=$(which kinit) || (echo 'ERROR! kinit command has not been found' && exit 1) #General kinit application file
        keytabfile=$(echo $@ | grep -o '[[:alnum:]_-.]*.keytab') #keytab file provided by user (if exist) 
        if [[ -n $keytabfile ]]; then 
                keytabfile=$(basename $keytabfile) #Only the keytab file name instead of full or relative path (in case of provided) 
        fi 
        original_cache_file="/tmp/krb5cc_$(id -u)" #Regular OS cache file name (depends on UID) 
        if [[ $1 == "--normal" ]]; then #Option to run regular kinit 
                shift 
                unset KRB5CCNAME 
                $os_kinit $@ 
                return $? 
        fi 
        if [[ -n $KRB5CCNAME ]]; then #Option to undo cache file changing in case of error 
                OLD_CACHE_FILE=$KRB5CCNAME 
        else 
                OLD_CACHE_FILE=$original_cache_file 
        fi 
        if [[ -n $keytabfile ]]; then #In case of keytab wasn't provided - cache file will not be changed 
                export KRB5CCNAME=/tmp/krb5cc_$(whoami)_${keytabfile%%.keytab} 
        fi 
        $os_kinit $@ #Runing kinit command 
        kinit_exit_status=$? #Saving the exit status of kinit command to return it to $stderr 
        if [[ $kinit_exit_status -ne 0 ]] && [[ -n $KRB5CCNAME ]]; then #Undo KRB5 ticket cache file changing in case of kinit error exit status (only if changed before) 
                export KRB5CCNAME=$OLD_CACHE_FILE 
        fi 
        return $kinit_exit_status #Provide the right exit status 
}
