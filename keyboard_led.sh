#!/usr/bin/env bash

#++++++++++++++++++++#
#--NH5xAx炫酷键盘灯效;
#++++++++++++++++++++#

#--Color Code;
Cls="\033[0m"       ;    White="\033[1;38m"
Red="\033[1;31m"    ;    Green="\033[1;32m"
Yellow="\033[1;33m" ;    Blue="\033[1;34m"
Purple="\033[1;35m" ;    Cyan_blue="\033[1;36m"

#--Kernel PATH;
Kernel_led_mode='/sys/devices/platform/tuxedo_keyboard/leds/rgb:kbd_backlight'
readonly Kernel_led_mode

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
    '0 0 255'       #蓝;
    '255 255 0'     #黄;
    '255 0 255'     #粉;
    '0 255 255'     #青;
    '255 255 255'   #白;
    '255 0 0'       #红;
    '0 255 0'       #绿;
)

# Led 亮度;
Led_Val() {
    echo $1 >${Kernel_led_mode}/brightness
}

# Led 灭;
Led_Low() {
    Led_Val 0
}

# Led 亮;
Led_High() {
    Led_Val 255
}

# 获取当前Led颜色;
Get_color() {
    now_color=$(cat ${Kernel_led_mode}/multi_intensity)
    echo ${new_color}
}

# 获取当前Led亮度;
Get_brig() {
    now_brig=$(cat ${Kernel_led_mode}/brightness)
    echo ${now_brig}
}

#Led初始化操作暴闪;
Led_init() {
    x=$1
    Led_High

    while ((x--)); do
        for i in "${Led_color[@]}"; do
            echo $i >${Kernel_led_mode}/multi_intensity
            sleep 0.3
        done
    done
}

case $1 in
    0)  #单色闪烁模式;
        while ((1))
        do
            Led_High
            sleep 1
            Led_Low
            sleep 1
        done
        ;;
    1)  #渐变模式;
        Led_High
        while ((1))
        do
            for i in "${Led_color[@]}"; do
                echo $i >${Kernel_led_mode}/multi_intensity
                sleep 1
            done
        done
        ;;
    2)  #单色呼吸灯模式;
        while ((1))
        do
            Led_High
            for ((i=255;i>=0;--i)); do
                sleep '0.02'
                Led_Val $i
                if (( ${i}==0 )); then
                    for ((m=${i};m<=255;++m)); do
                        sleep '0.03'        
                        Led_Val $m
                    done
                fi
            done
        done
        ;;
    3)  #渐变模式+呼吸灯,熄灭时变色;
        while ((1)); do
            Led_High
            for i in  "${Led_color[@]}"; do
                echo $i > ${Kernel_led_mode}/multi_intensity
                for ((i=255;i>=0;--i)); do
                    sleep '0.03'
                    Led_Val $i
                done
            done
        done
        ;;
    5)  #渐变模式+呼吸灯+熄灭时变色+提颜色亮度;
        Led_High
        while ((1))
        do
            x=0
            for i in  "${Led_color[@]}"; do
                echo $i > ${Kernel_led_mode}/multi_intensity
                for ((L=255;L!=0;--L)); do          
                    sleep '0.02'          #温柔的灭;  
                    Led_Val $L
                done
                if (( $L==0 )); then
                    Led_Low
                    ((x+=1))
                    echo ${Led_color[$x]}> ${Kernel_led_mode}/multi_intensity
                    for ((H=$L;H<=255;H++)); do
                        Led_Val $H
                        sleep '0.02'
                    done
                fi
            done
        done
        ;;
    6)  #按键盘灯光现,且每次灯光不一样;
        Led_Low
        while ((1))
        do
            for i in  "${Led_color[@]}"; do
                echo $i >${Kernel_led_mode}/multi_intensity
                if [ ! ${in} ]; then
                    in="$(read -sn1 > /dev/null 2>&1 )"
                    Led_High
                    sleep '0.1'
                    Led_Low
                fi
            done
        done
        ;;
    Up)
        a=$(Get_brig)
        if (($a<=255)); then
            ((a+=15))
            if (($a == 255)); then
                a=255
            else
                Led_Val $a
            fi
        fi
        ;;
    Down)
        a=$(Get_brig)
        if (($a>=0)); then
            ((a-=15))
            if (($a == -15)); then
                a=0
            else
                Led_Val $a
            fi
        fi
        ;;
    Switch)
        if (($(Get_brig) == 0)); then
            Led_High
        else
            Led_Low
        fi
        ;;
    Low)
        Led_Low
        ;;
    High)
        Led_High
        ;;
    init)
        Led_init 3
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
