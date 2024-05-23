#!/bin/bash
# by Tuinov Andrey voytmar @ yandex.ru
## 80-7d-3a-31-d9-b8


SERVER="narodmon.ru"
PORT="8283"

# MAC адрес прибора. Заменить на свой!
DEVICE_MAC="80-7d-3a-31-d9-b8"

# идентификатор прибора, для простоты добавляется 01 (02) к MAC прибора
SENSOR_ID_1=$DEVICE_MAC"01"
SENSOR_ID_2=$DEVICE_MAC"02"

# значения датчиков
sensor_value_1=-1.6
sensor_value_2=756

# устанавливаем соединение
exec 3<>/dev/tcp/$SERVER/$PORT

# отсылаем единичное значение датчика
#printf "#%s\n#%s#%s\n##" "$DEVICE_MAC" "$SENSOR_ID_1" "$sensor_value_1" >&3

# отсылаем множественные значения датчиков
printf "#%s\n#%s#%s\n#%s#%s\n##" "$DEVICE_MAC" "$SENSOR_ID_1" "$sensor_value_1" "$SENSOR_ID_2" "$sensor_value_2" >&3

# получаем ответ
read -r MSG_IN <&3
echo "$MSG_IN"

# закрываем соединение
exec 3<&-
exec 3>&-
