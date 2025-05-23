#### 1.0.0-04022025b

**Добавлено**
- Обновления по воздуху (OTA)
- Датчик переворота
- Датчик разрыва цепи маслонасоса

**Исправлено**
- Размытый текст и линии для отображения графиков
- Оптимизации кода
- Менее агрессивный режим поллинга датчиков диагностики
- Значительное уменьшение объема прошивки


#### 1.0.0-06022025b

**Добавлено**
- Моточасы в часах или минутах. Отдельные моточасы общего пробега и пробега на холостых оборотах.
- Автоматическое считывание ошибок в режиме диагностики. Ошибки так же автоматически убираются из списка при их стирании
- Иконка наличия обшибок ECU на табе в диагностическом интерфейсе
- Сетка с секундами в графиках
- Новая иконка соединения с блоком/ECU

**Исправлено**
- Улучшение UX обновления по воздуху
- Неверное определение УОЗ на XC (кантри) моделях (попытка исправить)
- Увеличен интервал множественного нажатия на внешнюю кнопку. Входить в диагностический и OTA режимы стало проще.
- Если выбран диагностический режим по умолчанию, при двойном нажатии на внешнюю кнопку происходит перезагрузка в режим кнопки
- VIN-код не считывался, если подключать устройсво к мотоциклу, подсоединенное к usb к кабелю
- Все темы приведены к одному стилю, различие только в цветах

#### 1.0.0-08022025b

**Добавлено**
- Компактный (и более симпатичный) переключатель карт

**Исправлено**
- VIN теперь запрашивается теперь только когда надо, а не постоянно
- Отображение "Ошибок нет" по центру


#### 1.0.0-11022025b

**Добавлено**
- Настраиваемые сервисные интервалы (до 4шт.) с функцией сброса
- Индикация необходимости сервиса при включении питания
- Индикация перегрева двигателя (настраиваемая)
- Индикация холодного двигателя (настраиваемая)
- Новая структура настроек

**Исправлено**
- Большая переделка кода интерфейса диагностики
- Если выключить в настройках DNS, то возможен доступ одновременно и к боксу, и к 3G сети. При этом бокс доступен по адресу http://192.168.11.1


#### 1.0.0-22022025c

**Добавлено**

- Тестовая поддержка KTM TPI 
- Цивилизованные выключатели для индикаторов температур в настройках
- Выключатель реакции на кнопку переключения карт в режиме поездки (для совместимости с родным мапсвитчером)
- Убраны десятые доли у МАП-датчиков
- Добавлена пауза после перед отображением "холодного двигателя" сразу после перекюлчения карт. После самого переключения сначала 5с показывается "новая" карта, затем уже отображается "холодный двигатель"
- Настраиваемая "маленькая" кнопка. Теперь короткое нажатие и длинное нажатие можно переопределить (например, на переключение карт). В итогде можно ездить без внешней кнопки карт вообще

**Исправлено**

- Всегда срабатывал режим отображения надобности сервиса при загрузке (ошибка определения текущих моточасов в режиме кнопки)
- Имя WiFi сети изменено на DIAGBOX-XXXXXX, т.к. планируется базовая поддержка KTM TPI
- Для диагностических версий бокса показывались "лишние" настройки


#### 1.0.0-05032025с

**Добавлено**

- Экспериментальные моточасы под нагрузкой

**Исправлено**

- Не работал график ДПДЗ для TPI
- Не работала внешняя индикация текущей карты на TPI
- Валидация значений сервисных интервалов при сохранении
- Фейслифтинг на интерфейсе сервисных интервалах и моточасах
- Более стабильная работа OTA
- Не работала загрузка в режим диагностики как в режим по умолчанию

- Нельзя было выставить стирание ошибок ЭБУ на короткое нажатие встроенной кнопки


#### 1.0.0-29032025с

**Исправлено**
- Слишком редкое обновление значений MAP на впуске для TPI
- Не читались и не стирались ошибки на TPI

#### 1.2.0-01042025с
**Добавлено**
- Поддержка TPI 18-19


#### 1.2.0-12042025с
**Исправлено**
- Более стабильная работа переключателя карт. Убраны нюансы в случае одновременной работе двух переключателей карт одновременно
- Исправлены нерабочие показатели аккумулятора для TPI 20+

#### 1.2.1-02052025с
**Добавлено**
- Описание ошибок (DTC)
- Чтение текущих и сохраненных ошибок в режиме диагностики
**Исправлено**
- Некорректно отдавалась температура воздуха в режиме телеметрии

#### 1.2.1-07052025с
**Исправлено**
- неверное описание ошибки 1405
- проценты ДПДЗ в режиме диагностики теперь отображаются как в OBD ("как в карсканнере"). В режиме телеметрии все как и было, 0-100.

#### 1.2.1-13052025с
**Добавлено**
- Отображение транспортной блокировки для KTM TBI
- Дробный угол дроссельной заслонки (для удобства регулировки ХХ)
- Дробный процент дроссельной заслонки (для удобства регулировки ХХ)