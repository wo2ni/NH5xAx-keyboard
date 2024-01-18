#!/usr/bin/env bash
#
#++++++++++++++#
#--炫酷键盘灯效;
#++++++++++++++#

#--Color Code;
Cls="\033[0m"       ;    White="\033[1;38m"
Red="\033[1;31m"    ;    Green="\033[1;32m"
Yellow="\033[1;33m" ;    Blue="\033[1;34m"
Purple="\033[1;35m" ;    Cyan_blue="\033[1;36m"

#--Kernel PATH;
Kernel_led_mode='/sys/devices/platform/tuxedo_keyboard/leds/rgb:kbd_backlight';readonly Kernel_led_mode

#|-----|----|------------|
#| 0   | 0  | 255   -> 蓝|
#| 255 | 255| 0     -> 黄| 
#| 255 | 0  | 255   -> 粉|
#| 0   | 255| 255   -> 青|
#| 255 | 255| 255   -> 白|
#| 255 | 0  | 0     -> 红|
#| 0   | 255| 0     -> 绿|
#|-----|----|------------|

Led_color=(
    '0   0   255'       #蓝;
    '255 255 0'         #黄;
    '255 0   255'       #粉;
    '0   255 255'       #青;
    '255 255 255'       #白;
    '255 0   0'         #红;
    '0   255 0'         #绿;
)

case $1 in
    0)  #单色闪烁模式;
        while ((1))
        do
            echo '255' > ${Kernel_led_mode}/brightness
            sleep 1
            echo '0' > ${Kernel_led_mode}/brightness
            sleep 1
        done
        ;;
    1)  #渐变模式;
        while ((1))
        do
            echo '255' > ${Kernel_led_mode}/brightness
            for ((color=1;color<${#Led_color[@]};++color))      #干掉0X000000;
            do
                for color_file in `ls -1 ${Kernel_led_mode}/color_*`
                do
                    echo "${Led_color[color]}" > ${color_file}
                done
                sleep '0.3'
            done
        done
        ;;
    2)  #单色呼吸灯模式;
        while ((1))
        do
            echo '255' > ${Kernel_led_mode}/brightness
            for ((i=255;i>=0;--i)); do
                sleep '0.02'        #0.03,贤惠温柔级,0.1,少妇级,0.01,风骚级;
                echo "${i}" > ${Kernel_led_mode}/brightness
                if (( ${i}==0 )); then
                    for ((m=${i};m<=255;++m)); do
                        sleep '0.03'        
                        echo "${m}" > ${Kernel_led_mode}/brightness
                    done
                fi
            done
        done
        ;;
    3)  #渐变模式+呼吸灯,熄灭时变色,--饥渴少妇型;
        while ((1))
        do
            for ((color=1;color<${#Led_color[@]};++color))      #干掉0X000000;
            do
                echo '255' > ${Kernel_led_mode}/brightness
                for color_file in `ls -1 ${Kernel_led_mode}/color_*`
                do
                    echo "${Led_color[color]}" > ${color_file}
                done
                for ((i=255;i>=0;--i)); do
                    sleep '0.03'        #温柔的灭;
                    echo "${i}" > ${Kernel_led_mode}/brightness
                done
            done
        done
        ;;
    5)  #渐变模式+呼吸灯+熄灭时变色+温柔提颜色亮度,--温柔小姐姐型;
        while ((1))
        do
            for ((color=1;color<${#Led_color[@]};++color))      #干掉0X000000;
            do
                echo '255' > ${Kernel_led_mode}/brightness
                for color_file in `ls -1 ${Kernel_led_mode}/color_*`
                do
                    echo "${Led_color[color]}" > ${color_file}
                done
                for ((L=255;L!=0;--L)); do          
                    sleep '0.02'          #温柔的灭;  
                    echo "${L}" > ${Kernel_led_mode}/brightness
                done
                if (( $L==0 )); then
                    echo '0' > ${Kernel_led_mode}/brightness
                    #echo 数组下标:${color}
                    case ${color} in        #核心变色;
                        7)
                            new_color='8'
                            ((new_color-=$color))
                            #echo 新的${new_color}
                            for Low_color_file in `ls -1 ${Kernel_led_mode}/color_*`
                            do
                                echo "${Led_color[${new_color}]}" > ${Low_color_file}
                            done
                            for ((H=0;H!=255;++H)); do
                                sleep '0.01'        #温柔的亮;
                                echo "${H}" > ${Kernel_led_mode}/brightness
                            done
                            ;;
                        *)
                            new_color='1'
                            ((new_color+=$color))
                            #echo 新的${new_color}
                            for Low_color_file in `ls -1 ${Kernel_led_mode}/color_*`
                            do
                                echo "${Led_color[${new_color}]}" > ${Low_color_file}
                            done
                            for ((H=0;H!=255;++H)); do
                                sleep '0.01'        #温柔的亮;
                                echo "${H}" > ${Kernel_led_mode}/brightness
                            done
                            ;;
                    esac
                fi
            done
        done
        ;;
    6)  #按键盘灯光现,且没次灯光不一样,美就完了;
        while ((1))
        do
            echo '0' > ${Kernel_led_mode}/state
            for ((color=1;color<${#Led_color[@]};++color))      #干掉0X000000;
            do
                for color_file in `ls -1 ${Kernel_led_mode}/color_*`    #灯光区域;
                do
                    echo "${Led_color[color]}" > ${color_file}
                done
                if [ ! ${in} ]; then
                    in="$(read -sn1 > /dev/null 2>&1 )"
                    echo '255' > ${Kernel_led_mode}/brightness
                    echo '1' > ${Kernel_led_mode}/state
                    sleep '0.3'
                    echo '0' > ${Kernel_led_mode}/state
                fi
            done
        done
        ;;
    close)
        echo '0' >"${Kernel_led_mode}/brightness"
        ;;
    init)
        echo '255' >"${Kernel_led_mode}/brightness"
        ;;
    *)  #使用帮助;
        clear
        printf "\t${Red}#++++++++++++++++++++#${Cls}\n\a"
        printf "\t${Yellow}#NH5xAx,炫酷键盘灯效.${Cls}\n"
        printf "\t${Red}#++++++++++++++++++++#${Cls}\n"
        printf "共计<--${Red}6${Cls}-->${Green}种模式.${Cls}\n"
        printf "<--${Green}0${Cls}-->${Blue}单色闪烁模式.${Cls}\n"
        printf "<--${Blue}1${Cls}-->${White}循环变化模式.${Cls}\n"
        printf "<--${White}2${Cls}-->${Cyan_blue}单色呼吸模式.${Cls}\n"
        printf "<--${Cyan_blue}3${Cls}-->${Yellow}循环变色+呼吸灯<模式0>.${Cls}\n"
        printf "<--${Yellow}5${Cls}-->${Purple}循环变色+呼吸灯<模式1>.${Cls}\n"
        printf "<--${Purple}6${Cls}-->${Red}按键盘任意键,亮灯光,<测试模式>.${Cls}\n"
        ;;
esac
