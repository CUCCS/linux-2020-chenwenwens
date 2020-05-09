#!/usr/bin/env bash
set -o pipefail

LANG=en_US.UTF-8


function HelpInfo {
	echo -e "task3.sh - For Web Client Access Log Analysing.\n"
	echo -e "Tips: 1. Before using this script, use 'wget http://sec.cuc.edu.cn/huangwei/course/LinuxSysAdmin/exp/chap0x04/web_log.tsv.7z'\
	to download web_log.tsv.7z
      2. Be sure you have installed 'p7zip-full', otherwise, use 'sudo apt install p7zip-full' to install, then use '7z x web_log.tsv.7z' to unzip.\n"
	echo "Usage: bash weblog.sh [arguments]"
	echo "Arguments:"
	echo "  -o		: Top 100 hosts and appearing times."
	echo "  -i		: Top 100 IP and appearing times."
	echo "  -u		: Top 100 URL accessed most frequently"
	echo "  -s		: Appearing times and ratio of diffrent response status code"
	echo "  -u4		: Top 10 URL and appearing times by diffrent 4XX status code"
	echo "  -uh <URL>	: Given URL, print top 100 hosts accessed"
	echo "  -h or --help	: Print Help (this message) and exit."
}

function HostsTop100 {
	host=$(sed '1d' "$1" | awk -F '\t' '{print $1}' | sort | uniq -c | sort -nr | head -n 100)
	echo -e "$host"  # >>host_top_100.log
}

function IPTop100 {
	IP=$(sed '1d' "$1" | awk '{if ($1~/^([0-2]*[0-9]*[0-9])\.([0-2]*[0-9]*[0-9])\.([0-2]*[0-9]*[0-9])\.([0-2]*[0-9]*[0-9])$/){print $1}}'| awk -F '\t' '{a[$1]++} END{for(i in a) {print (a[i],i)}}' | sort -nr | head -n 100)
	echo -e "$IP" # >>IP_top_100.log
}

function URLTop100 {
	URL=$(sed '1d' "$1" | awk -F '\t' '{print $5}' | sort | uniq -c | sort -nr | head -n 100)
	echo -e "$URL" # >>URL_top_100.log
}

function StatusCode {
	code=$(sed '1d' "$1" | awk -F '\t' 'BEGIN{ans=0}{a[$6]++;ans++} END{for(i in a) {printf ("%-10s %-10d %10.3f%\n",i,a[i],a[i]*100/ans)}}')
	echo -e "$code" # >>status_code.log
}

function URL4XX {
    u4=$(sed '1d' "$1" | awk -F '\t' '{print $6}' | grep -E "^4[[:digit:]]" | sort -u )
    for n in $u4 ; do 
        top=$(awk -F '\t' '{ if($6=='"$n"') {a[$5]++}} END {for(i in a) {print a[i],i}}' "$1"| sort -nr | head -n 10)
        echo -e "${n} Top10 URL:\n$top\n"  # >>4xx_top10_url.log
    done
}

function URLHosts {
	uh=$(sed '1d' "$1" | awk -F '\t' '{if($5=="'"$2"'") {a[$1]++}} END{for (i in a) {print a[i],i}}' | sort -nr | head -n 100)
	echo -e "URL: $2\n\n${uh}" # >>specified_URL_host.log
}

if [[ "$#" -eq 0 ]]; then 
	echo -e "Please input some arguments, refer the Help information below:\n"
	HelpInfo
fi
while [[ "$#" -ne 0 ]]; do
	case "$1" in
		"-o")HostsTop100 "web_log.tsv" ; shift;;
		"-i")IPTop100 "web_log.tsv" ; shift;;
		"-u")URLTop100 "web_log.tsv" ; shift;;
		"-s")StatusCode "web_log.tsv" ; shift;;
		"-u4")URL4XX "web_log.tsv" ; shift;;
		"-uh")
			if [[ -n "$2" ]]; then
				URLHosts "web_log.tsv" "$2"
            else
                echo "Please input an URL after '-uh'."
				exit 0
            fi
			shift 2;;		
		"-h" | "--help")HelpInfo; exit 0
	esac
done	
