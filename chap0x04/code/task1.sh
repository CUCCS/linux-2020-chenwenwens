#!/usr/bin/env bash
set -o pipefail

LANG=en_US.UTF-8

function HelpInfo {
	echo -e "image.sh - For Images Batch Processing.\n"
	echo -e "Tips: Before using this script, be sure you have installed ImageMagick, or input 'sudo apt install imagemagick' to install.\n"
	echo "Usage: bash image.sh [arguments]"
	echo "Arguments:"
	echo "  -i <path>		: Iuput the path of images dictionary."
	echo "  -q <percentage>	: Compress the quality of JPG images, 
			  eg: -q 50% (means compress 50%)."
	echo "  -r <width>		: Compress the resolution of JPEG/PNG/SVG images, 
			  eg: -r 50 (means compress width to 50)."
	echo "  -w <text>		: Embed text watermark in all images."
	echo "  -p <text>		: Rename all files by adding prefix."
	echo "  -s <text>		: Rename all files by adding suffix."
	echo "  -c			: Convert PNG/SVG images to JPEG images."
	echo "  -h or --help		: Print Help (this message) and exit."
}

function QualityCompress {
	# $1:dictionary; $2:percentage for quality compressing
	[ -d "qc_output" ] || mkdir "qc_output"
	j_images="$(find "$1" -regex '.*\(jpg\|JPG\|jpeg\)')"
	for img in $j_images; do
		fullname="$(basename "$img")"
		filename="${fullname%.*}"
		typename="${fullname##*.}"
		convert "$img" -quality "$2" ./qc_output/"$filename"."$typename"
	done
	echo "Finished quality compressing."
}
function ResolutionCompress {
	# $1:dictionary; $2: width for resolution compressing
	[ -d "rc_output" ] || mkdir "rc_output"
	jps_images="$(find "$1" -regex '.*\(jpg\|JPG\|jpeg\|png\|PNG\|svg\|SVG\)')"
	for img in $jps_images; do
		fullname="$(basename "$img")"
		filename="${fullname%.*}"
		typename="${fullname##*.}"
		convert "$img" -resize "$2" ./rc_output/"$filename"."$typename"
	done
	echo "Finished resolution compressing."
}

function WatermarkEmbed {
	# $1: dictionary; $2: watermark text
	[ -d "wm_output" ] || mkdir "wm_output"
	jps_images="$(find "$1" -regex '.*\(jpg\|JPG\|jpeg\|png\|PNG\|svg\|SVG\)')"
	for img in $jps_images; do
		fullname="$(basename "$img")"
		filename="${fullname%.*}"
		typename="${fullname##*.}"
		convert "$img" -fill red -pointsize 60 -draw "text 60,60 '$2'" ./wm_output/"$filename"."$typename"
	done
	echo "Finished watermark embedding."
}

function Prefix {
	# $1: dictionary; $2: prefix
	for img in "$1"*.*; do
		fullname="$(basename "$img")"
		filename="${fullname%.*}"
		typename="${fullname##*.}"
		[ -d "pf_output" ] || mkdir "pf_output"
		cp -- "$img" ./pf_output/"$2""$filename"."$typename"
	done
	echo "Finished prefix adding."
}

function Suffix {
	# $1: dictionary; $2: suffix
	for img in "$1"*.*; do
		fullname="$(basename "$img")"
		filename="${fullname%.*}"
		typename="${fullname##*.}"
		[ -d "sf_output" ] || mkdir "sf_output"
		cp -- "$img" ./sf_output/"$filename""$2"."$typename"
	done
	echo "Finished suffix adding."
}

function Conversion {
	[ -d "cv_output" ] || mkdir "cv_output"
	ps_images="$(find "$1" -regex '.*\(png\|PNG\|svg\|SVG\)')"
	for img in $ps_images; do
		fullname="$(basename "$img")"
		filename="${fullname%.*}"
		convert "$img" ./cv_output/"$filename"".jpg"
	done
	echo "Finished coverting to JPEG."
}

dir=""
if [[ "$#" -eq 0 ]]; then 
	echo -e "Please input some arguments, refer the Help information below:\n"
	HelpInfo
fi
while [[ "$#" -ne 0 ]]; do
	case "$1" in
		"-i")
			if [[ -n "$2" ]]; then 
				dir="$2"
			else 
				echo "Please input a path after '-i'."
				exit 0
			fi
			shift 2;;
		"-q")
			if [[ -n "$2" ]]; then 
				QualityCompress "$dir" "$2"
			else 
				echo "Please input a quality argument. eg: -q 50%"
				exit 0
			fi
			shift 2;;
				
		"-r")
			if [[ -n "$2" ]]; then 
				ResolutionCompress "$dir" "$2"
			else 
				echo "please input a percentage for resizing. eg: -r 50"
				exit 0
			fi
			shift 2;;

		"-w")
			if [[ -n "$2" ]]; then 
				WatermarkEmbed "$dir" "$2"	
			else 
				echo "Please input a watermark text. eg: -w hello"
				exit 0
			fi
			shift 2;;
		"-p")
			if [[ -n "$2" ]]; then 
				Prefix "$dir" "$2"
			else
				echo "Please input some words after '-p'(for prefix)"
				exit 0
			fi
			shift 2;;
		"-s")
			if [[ -n "$2" ]]; then 
				Suffix "$dir" "$2"
			else
				echo "Please input some words after '-s'(for suffix)"
				exit 0
			fi		
			shift 2;;			
		"-c")
			Conversion "$dir"; shift;;
				
		"-h" | "--help")
			HelpInfo
			exit 0		
	esac
done	
