#!/bin/bash

read -p "Введите адрес или IP для пинга: " address

fail_count=0
max_fail_count=3
ping_threshold=100
interval=1

if ! ping -c 1 -W 1 "$address" &>/dev/null; then
    echo "Адрес $address недоступен. Проверьте подключение."
    exit 1
fi

while true; do
    ping_result=$(ping -c 1 -W 1 "$address" 2>/dev/null | awk -F'time=' '/time=/ {print $2}' | awk '{print $1}')

    if [[ -z $ping_result ]]; then

        fail_count=$((fail_count + 1))
        echo "Пинг не выполнен. Ошибка #$fail_count"
    else

        fail_count=0

        if (( $(echo "$ping_result > $ping_threshold" | bc -l) )); then
            echo "Время пинга больше $ping_threshold мс: $ping_result мс"
        else
            echo "Пинг успешен: $ping_result мс"
        fi
    fi

    if [[ $fail_count -ge $max_fail_count ]]; then
        echo "Проблемы с подключением: $max_fail_count неудачных пингов подряд."
        fail_count=0
    fi

    sleep $interval
done
