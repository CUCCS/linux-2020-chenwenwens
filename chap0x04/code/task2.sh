#!/usr/bin/env bash
set -o pipefail

LANG=en_US.UTF-8

# Group	Country	Rank	Jersey	Position	Age	Selections	Club	Player	Captain

function HelpInfo {
	echo -e "task2.sh - For World Cup Player Infomation Statistics Analysing.\n"
	echo -e "Tips: Before using this script, use 'https://github.com/c4pr1c3/LinuxSysAdmin/blob/master/exp/chap0x04/worldcupplayerinfo.tsv' to download worldcupplayerinfo.tsv\n"
	echo "Usage: bash player.sh [arguments]"
	echo "Arguments:"
	echo "  -ar		: Num and percentage of players with their age in specific range."
	echo "  -ac		: Names of the oldest and the youngest players."
	echo "  -p		: Num and percentage of players on diffrent positions."
	echo "  -n		: Names of players with the longest name length."
	echo "  -h or --help	: Print Help (this message) and exit."
}

below20=0
between20and30=0
above30=0

max_age=0
min_age=1024

longest_name_len=0
shortest_name_len=1024

# 全局关联数组
declare -A -g positions_dict

line_num=0

function AgeRange {
	age_column=$(awk -F "\t" '{ print $6 }' "$1")
	for age in $age_column; do
		if [[ "$age" != 'Age' ]]; then 
			if [[ "$age" -lt 20 ]];then
			  below20=$((below20+1))
			elif [[ "$age" -ge 20 && "$age" -le 30 ]];then
			  between20and30=$((between20and30+1))
			elif [[ "$age" -gt 30 ]];then
			  above30=$((above30+1))
			fi
			line_num=$((line_num+1))
		fi
	done
	
	below20_ratio=$(printf "%.3f" "$(echo "100*${below20}/$line_num" | bc -l)")
	between20and30_ratio=$(printf "%.3f" "$(echo "100*${between20and30}/$line_num" | bc -l)")
	above30_ratio=$(printf "%.3f" "$(echo "100*${above30}/$line_num" | bc -l)")
	# above30_ratio=$(echo "scale=4; 100*${above30}/$line_num" | bc)
	
	echo -e "\n-------- Age Statistics --------"
	echo -e "(0, 20) \t$below20\t${below20_ratio}%"
	echo -e "[20, 30]\t$between20and30\t${between20and30_ratio}%"
	echo -e "(30, +∞)\t$above30\t${above30_ratio}%"
}

function Position {
	position_column=$(awk -F "\t" '{ print $5 }' "$1")
	
	for position in $position_column; do
		if [[ "$position" != 'Position' ]];then
			if [[ -z "${positions_dict[$position]}" ]];then
				positions_dict[$position]=1
			else
				temp="${positions_dict[$position]}"
				positions_dict[$position]=$((temp+1))
			fi
			line_num=$((line_num+1))
		fi
	done
	
	echo -e "\n-------- Positions Statistics --------"
	for position in "${!positions_dict[@]}";do
		count="${positions_dict[$position]}"
		ratio=$(printf "%.3f" "$(echo "100*${count}/$line_num" | bc -l)")
		echo -e "$position\t$count\t${ratio}%"
	done
}

function AgeCompare {
	age_column=$(awk -F "\t" '{ print $6 }' "$1")
	for age in $age_column; do
		if [[ "$age" != 'Age' ]]; then 
			if [[ "$min_age" -gt "$age" ]]; then
				min_age="$age"
			fi
			if [[ "$max_age" -lt "$age" ]]; then
				max_age="$age"
			fi
			line_num=$((line_num+1))
		fi
	done
	
	oldst_name_column=$(awk -F '\t' '{if($6=='"${max_age}"') {print $9}}' "$1");
	echo -e "\n-------- Oldest Names --------"
	for oldst_name in $oldst_name_column; do
		echo -e "$oldst_name\t$max_age"
	done
	
	youngest_name_column=$(awk -F '\t' '{if($6=='"$min_age"') {print $9}}' "$1");
	echo -e "\n-------- Youngest Names --------"
	for youngest_name in $youngest_name_column ;do
		echo -e "$youngest_name\t$min_age"
	done
}

function Name {
	name_len_column=$(awk -F "\t" '{ print length($9) }' "$1")
	for name_len in $name_len_column; do
		if [[ "$longest_name_len" -lt "$name_len" ]]; then
			longest_name_len="$name_len"
		fi
		if [[ "$shortest_name_len" -gt "$name_len" ]]; then
			shortest_name_len="$name_len"
		fi
	done
	
	longest_name_column=$(awk -F '\t' '{if (length($9)=='"$longest_name_len"'){print $9}}' "$1")
	echo -e "\n-------- Longest Names --------"
	echo -e "$longest_name_column\t$longest_name_len"
	
	shortest_name_column=$(awk -F '\t' '{if (length($9)=='"$shortest_name_len"'){print $9}}' "$1")
	echo -e "\n-------- Shortest Names --------"
	echo -e "$shortest_name_column\t$shortest_name_len"
}

if [[ "$#" -eq 0 ]]; then 
	echo -e "Please input some arguments, refer the Help information below:\n"
	HelpInfo
fi
while [[ "$#" -ne 0 ]]; do
	case "$1" in
		"-ar")AgeRange "worldcupplayerinfo.tsv"; shift;;
		"-ac")AgeCompare "worldcupplayerinfo.tsv"; shift;;
		"-p")Position "worldcupplayerinfo.tsv"; shift;;
		"-n")Name "worldcupplayerinfo.tsv"; shift;;
		"-h" | "--help")HelpInfo; exit 0
	esac
done	
