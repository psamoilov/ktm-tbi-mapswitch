# V3: подключение клиента по WiFi (технические юзкейсы)

Человекочитаемые **юзкейсы** (акторы, триггеры, основной поток, альтернативы) — в [`wifi-v3-manual-use-cases.md`](wifi-v3-manual-use-cases.md).

Документ описывает **как пользователь или телефон попадает в веб-интерфейс** устройства в ревизии V3. База: SoftAP без пароля, фиксированный IP точки `192.168.11.1`, имя сети из MAC (`2TBOX-` + 12 hex), см. `include/config/Config.h` и `NetworkHelpers::startWiFiAP`.

Для V3 в сборке включены `DIAGBOX_FEAT_WIFI_ON_STARTUP` и `DIAGBOX_FEAT_QR_ONBOARDING` (`include/config/V3/features.h`).

---

## Атомарные сценарии для тестов (сводка)

| ID | Ожидаемый результат | Источник / параметр |
|----|---------------------|---------------------|
| **UC-WIFI-AUTO** | Поднят AP с политикой **automatic**, таймауты из `WifiPolicy::automatic()` | Обычный boot + `DIAGBOX_FEAT_WIFI_ON_STARTUP`, без `FEAT_DIAG_ONLY` |
| **UC-WIFI-FORCED** | Поднят AP с политикой **forced**, `UI::Mode::Diagnostic` | Любой триггер из таблицы в §3 |
| **UC-QR-WIFI** | На дисплее QR `WIFI:T:nopass;S:<SSID>;;` | Диагностический UI + `WIFI_STATE_ON` (см. §4) |
| **UC-QR-URL** | QR с `http://192.168.11.1/` | Диагностический UI + `WIFI_STATE_CONNECTED` без перехода в `ACTIVE` |
| **UC-QR-LATCH** | После `WIFI_STATE_ACTIVE` QR скрыт и не появляется снова, пока выполняются условия latch | §4, сброс latch в §4.1 |

Проверка **итогового состояния** (политика, `wifiStatus`, экран QR) параметризуется триггером; сами триггеры forced — не отдельные юзкейсы, а входы в один сценарий **UC-WIFI-FORCED**.

---

## 1. Общая модель

| Элемент | Поведение |
|---------|-----------|
| Режим WiFi | Только AP (STA нет), клиент подключается **к** коробке |
| Аутентификация WiFi | Открытая сеть (`nopass` в QR и в прошивке) |
| Адрес сервиса | `http://192.168.11.1/` (в QR при онбординге после подключения к AP) |
| DNS «как домен» | Настройка **`dns`** в NVS/JSON: `Settings::IDX_dns`, чтение через `Settings::getDNS()`. Значения `Settings::STATE`: `ON = 1`, `OFF = 2` (по умолчанию в таблице настроек часто `OFF`). Если `getDNS() != STATE::OFF`, после появления первой станции вызывается `NetworkHelpers::startDNS` (ответ `*` → `192.168.11.1`); в `startWiFiAP` передаётся `withoutGateway = (getDNS() == OFF)`, то есть при включённом DNS у AP задаётся шлюз `WLAN_AP_GATEWAY_IP`. В UI это описано как доступ по `ktm.top`; **в QR всегда прошит IP**, не имя |
| Мощность передатчика | V3: `Settings::getWifiTxPowerDbm()` передаётся в `WiFi.setTxPower` (255 = дефолт ядра) |

### 1.1 Политики и таймауты (ссылка на код)

Структура `WifiPolicy` и фабрики заданы в `src/modes/DefaultMode.h`:

```13:19:src/modes/DefaultMode.h
struct WifiPolicy {
    uint32_t idleTimeoutMs;
    uint32_t waitClientMs;
    bool persistent;       // idle timer paused while any client connected

    static constexpr WifiPolicy automatic() { return {60000,  60000,  false}; }
    static constexpr WifiPolicy forced()    { return {120000, 120000, true}; }
};
```

| Политика | `waitClientMs` | `idleTimeoutMs` | `persistent` |
|----------|----------------|-----------------|--------------|
| **automatic** | 60 000 | 60 000 | `false` |
| **forced** | 120 000 | 120 000 | `true` |

В цикле обслуживания при `persistent && active` таймер простоя дополнительно «подкручивается» (`lastActivity = now`), см. `src/modes/DefaultMode.cpp` (`runWifi`).

---

## 2. UC-WIFI-AUTO: старт AP при обычном включении

**Условие:** прошивка с `DIAGBOX_FEAT_WIFI_ON_STARTUP`, boot не в режиме «только диагностика».

**Поток:** `DefaultMode::start()` → `startWifi(WifiPolicy::automatic())`.

**Смысл для пользователя:** поднимается `2TBOX-XXXXXXXXXXXX`; если за `waitClientMs` (**60 с**) ни одна станция не подключилась, задача WiFi завершает фазу ожидания и уходит в `cleanup` (AP отключается). После появления клиентов действует `idleTimeoutMs` (**60 с**) от последней активности (логика в `runWifi`).

**Варианты подключения клиента:**

1. **Вручную:** SSID в настройках WiFi, браузер `192.168.11.1`.
2. **QR:** **не** задействуется при «чистом» UC-WIFI-AUTO: в `startWifi()` режим `UI::Mode::Diagnostic` выставляется только при `policy.persistent` (т.е. для **forced**). Пока действует только **automatic**, `updateQrOnboarding()` сразу выходит (не Diagnostic) и гасит QR. QR возможен после **UC-WIFI-FORCED** (или эквивалента), см. §4.

---

## 3. UC-WIFI-FORCED: один юзкейс, несколько триггеров

**Итоговое состояние:** AP работает с политикой **forced** (`waitClientMs` / `idleTimeoutMs` = **120 с** / **120 с**, `persistent == true`), `UI::instance->operationMode == UI::Mode::Diagnostic`.

Это **не** перезапуск SoftAP и **не** новая FreeRTOS-задача, если WiFi уже крутится: достаточно сменить атомарно `policyType_` и при необходимости выставить режим UI.

| Триггер | Условие | Код |
|---------|---------|-----|
| Сборка diag-only | `Software::hasFeature(Software::FEAT_DIAG_ONLY)` | `DefaultMode::start()` → сразу `startWifi(forced)` |
| Ранний клик при boot | `DIAGBOX_FEAT_ECU_NOSLEEP`, первые ~3 с, `SingleClick` | `main.cpp` interceptor → `ensureForced()` |
| Кнопка **diag / wake-wifi** | Назначенные действия или четырёхклик | `buttons.h`: `DIAG_MODE`, `TOGGLE_WAKELOCK_WIFI` → `toggleWifi()` |

### 3.1 Переход auto → forced без пересоздания сессии

`ensureForced()` (`src/modes/DefaultMode.cpp`):

- Если WiFi-задача **уже** запущена и политика была **auto**, выполняется только `policyType_.store(POLICY_FORCED)` и `operationMode = Diagnostic`.
- Задача `wifiTaskFunction` **не** останавливается и **не** создаётся заново; `NetworkHelpers::startWiFiAP` **повторно не вызывается**.

**Для теста:** у уже подключённой станции ассоциация с AP не должна разрываться **только из-за** смены политики; меняются пороги `waitClientMs` / `idleTimeoutMs` и ветки «persistent + active».

### 3.2 Семантика `toggleWifi()`

- WiFi **выключен** → `startWifi(forced)`.
- WiFi **включен, политика auto** → `ensureForced()` (см. выше).
- WiFi **уже forced** → `stopWifi()` (флаг `wifiStopRequested_`, выход из цикла, `cleanupWifi`).

---

## 4. QR-онбординг (UC-QR-WIFI / UC-QR-URL / UC-QR-LATCH)

**Условие:** `DIAGBOX_FEAT_QR_ONBOARDING`, `GUI::updateQrOnboarding()` в `src/UI/GUI/GUI.cpp`.

Поведение **над** уже поднятым AP: раздел логически отделён от §2–3, но состояния берутся из `DefaultMode::runWifi` → `UI::wifiStatus`.

### 4.1 Когда показывается какой QR

Логика активна **только** при `operationMode == UI::Mode::Diagnostic`. Иначе вызывается `hideQrScreen()` и **`qrOnboardingLatched_ = false`**.

| `UI::WifiState` | Условие в прошивке | QR |
|-----------------|-------------------|-----|
| `WIFI_STATE_ON` | AP поднят, число станций **0** (в т.ч. все отключились в фазе обслуживания — см. `runWifi`, ветка `clientsQty == 0`) | **UC-QR-WIFI:** `WIFI:T:nopass;S:<SSID>;;`, подписи «WiFi» и SSID |
| `WIFI_STATE_CONNECTED` | `clientsQty > 0`, но **нет** «активности» веб-клиента | **UC-QR-URL:** `http://192.168.11.1/` |
| `WIFI_STATE_ACTIVE` | Есть активность веб-клиента | QR скрыт, **UC-QR-LATCH:** `qrOnboardingLatched_ = true` |

### 4.2 Граница CONNECTED ↔ ACTIVE (для тестов)

В `runWifi` (`src/modes/DefaultMode.cpp`):

- `active = clientPresent || recentPing`
- `clientPresent = server.hasEventSourceClients()` (SSE)
- `recentPing`: `lastPing = server.getLastPingTime()`, и считается «свежим», если `lastPing != 0` и `(now - lastPing) <= WIFI_PING_TIMEOUT`
- **`WIFI_PING_TIMEOUT` = 5000** (мс), константа в `src/modes/DefaultMode.h`

То есть **ACTIVE**, если хотя бы один поток EventSource открыт **или** с момента последнего ping прошло не более **5 секунд**.

### 4.3 Latch

- **Ставится** при переходе в `WIFI_STATE_ACTIVE`: дальше `if (qrOnboardingLatched_) return;` блокирует повторный показ WiFi/URL QR до сброса.
- **Сбрасывается** при **`operationMode != Diagnostic`**: в начале `updateQrOnboarding()` выполняется `qrOnboardingLatched_ = false` (и скрытие QR). Режим **Default** выставляется, например, в `DefaultMode::cleanupWifi()` — `UI::instance->operationMode = UI::Mode::Default` — то есть после полного завершения WiFi-сессии latch на следующем кадре GUI гарантированно сбрасывается, когда диагностический режим снят.

**Отложенный показ:** если активен пост-логотипный таймер (`logoTimer2_`), выставляется `qrPending_` вместо немедленного `showQrNow()` — см. обработку `ACT_QR_SHOW` в `GUI::tick()`.

**Ограничения:**

- В QR не подставляется `ktm.top`, только IP.
- Сеть в QR по-прежнему без пароля (`nopass`).

---

## 5. Сводка путей к веб-интерфейсу (основной режим V3)

1. **UC-WIFI-AUTO** — краткая сессия AP после включения.
2. **UC-WIFI-FORCED** — любой триггер из §3; стабильнее таймауты и режим диагностики.
3. Поверх AP — **UC-QR-*** (фазы WiFi-строка → URL → скрытие с latch).
4. Fallback без QR — ручной SSID и `192.168.11.1`.

---

## 6. Смежные режимы

- **OTA / CanHacker** — отдельные режимы загрузки, тот же хелпер AP/DNS по конфигу ревизии.
- Префикс SSID: **V3** — `2TBOX-`; в пользовательских текстах для V2 может встречаться `DIAGBOX-`.

---

## 7. Ссылки на код

| Тема | Файлы |
|------|--------|
| `WifiPolicy`, `WIFI_PING_TIMEOUT`, политика/таймауты | `src/modes/DefaultMode.h`, `src/modes/DefaultMode.cpp` |
| `ensureForced`, `toggleWifi`, `cleanupWifi`, FSM WiFi | `src/modes/DefaultMode.cpp` |
| AP / DNS / имя сети | `src/utils/NetworkHelpers.h`, `include/config/Config.h` |
| Настройка DNS | `Settings::IDX_dns`, `getDNS()`, `include/Settings.h` |
| QR, latch, сброс при выходе из Diagnostic | `src/UI/GUI/GUI.cpp` |
| Кнопки | `src/buttons.h`, `src/main.cpp` (boot interceptor) |
