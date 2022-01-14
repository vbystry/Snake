tput clear

segment=▪
first=●

fruit="\e[33m◈"

game_over=0

toDeleteX=0
toDeleteY=0


Color=("\e[31m" "\e[32m")

declare -a snakeX
declare -a snakeY

declare -A snake

declare -A XY

carry=0

moveX=0
moveY=0

snake_size=1

tput civis

x=$(tput cols)
let x--
y=$(tput lines)

let "fruitX=$RANDOM%$x"
let "fruitY=$RANDOM%$y"

move_snake(){
    let "index = snake_size-1"
    let "firstX=(${snakeX[index]}+moveX+x)%x"
    let "firstY=(${snakeY[index]}+moveY+y)%y"

    let "toDeleteX=${snakeX[0]}+1"
    toDeleteY=${snakeY[0]}

    if [ "$firstX" != "$fruitX" -o "$firstY" != "$fruitY" ]
    then
        snakeX=("${snakeX[@]:1}")
        snakeY=("${snakeY[@]:1}")
    else
        let "fruitX=$RANDOM%$x"
        let "fruitY=$RANDOM%$y"

        let snake_size++
    fi

    snakeX+=("$firstX")
    snakeY+=("$firstY")
}

draw_snake(){
    tput cup 0 0
    unset XY
    declare -A XY
    let "p=snake_size-2"
    for i in $(seq 0 1 $p)
    do
        v=${snakeX[i]}
        g=${snakeY[i]}
        let "colorNum=(i+snake_size-1)%2"
        XY[$v,$g]+="${Color[colorNum]}$segment"
    done

    if [ "${XY[$firstX,$firstY]}" = "\e[31m$segment" -o "${XY[$firstX,$firstY]}" = "\e[32m$segment" ]
    then
        game_over=1
    else
        XY[$firstX,$firstY]="\e[31m$first"
    fi

    sortedY=($(echo ${snakeY[*]} | tr " " "\n" | sort -nu))

    index=${sortedY[0]}
    
    if [ "$toDeleteY" != "${snakeY[0]}" ]
    then
        space=' '
        echo -e "\e[$toDeleteY;${toDeleteX}H$space"
    fi

    unset line
    
    line=""

    if [ "$index" -eq "$fruitY" ]
    then
        for m in $(seq 0 1 $x)
        do
            if [ "$m" != "$fruitX" ]
            then
                if [ "${XY[$m,$index]}" = "" ]
                then
                    line+=' '
                else
                    line+=${XY[$m,$index]}
                fi
            else
                line+=$fruit
            fi

        done 
    else
        for m in $(seq 0 1 $x)
        do
            if [ "${XY[$m,$index]}" = "" ]
            then
                line+=' '
            else
                line+=${XY[$m,$index]}
            fi
            
        done 
    fi
    echo -e "\e[$index;0H$line"
    position=$index

    for index in ${sortedY[@]:1}
    do
        line=""

        if [ "$index" -eq "$fruitY" ]
        then
            for m in $(seq 0 1 $x)
            do
                if [ "$m" != "$fruitX" ]
                then
                    if [ "${XY[$m,$index]}" = "" ]
                    then
                        line+=' '
                    else
                        line+=${XY[$m,$index]}
                    fi
                else
                    line+=$fruit
                fi
            done 
        else
            for m in $(seq 0 1 $x)
            do
                if [ "${XY[$m,$index]}" = "" ]
                then
                    line+=' '
                else
                    line+=${XY[$m,$index]}
                fi
            done 
        fi

        let position++

        if [ "$position" != "$index" ] 
        then
            echo -e "\e[$index;0H$line"
            let "position=$index+1"
        else
            echo -e "$line"
        fi
        unset line
    done

    let "fX=$fruitX+1"

    echo -e "\e[${fruitY};${fX}H$fruit"
}

let "snakeX[0]=$RANDOM%$x"
let "snakeY[0]=$RANDOM%$y"

moveX=1

while [ "$game_over" -eq 0 ]
do
    read -n 1 -s -t 0.1 direction
    stty -echo

    if [ "$direction" = "w" ]
    then
        moveX=0
        moveY="-1"
    elif [ "$direction" = "s" ]
    then
        moveX=0
        moveY=1
    elif [ "$direction" = "a" ]
    then
        moveX="-1"
        moveY=0
    elif [ "$direction" = "d" ]
    then
        moveX=1
        moveY=0
    fi
    move_snake
    draw_snake
    
    stty echo
    
done
echo "game over"