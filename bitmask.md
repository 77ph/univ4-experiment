Bit № | Hook Name                | Описание
--------------------------------------------------------
  0   | BEFORE_INITIALIZE        | Вызывается перед инициализацией пула
  1   | AFTER_INITIALIZE         | Вызывается после инициализации пула
  2   | BEFORE_MODIFY_POSITION   | Перед изменением ликвидности (add/remove)
  3   | AFTER_MODIFY_POSITION    | После изменения ликвидности
  4   | BEFORE_SWAP              | Перед свапом
  5   | AFTER_SWAP               | После свапа
  6   | BEFORE_DONATE            | Перед `donate()`
  7   | AFTER_DONATE             | После `donate()`
  8   | BEFORE_SETTLE            | Перед `settle()`
  9   | AFTER_SETTLE             | После `settle()`
 10   | BEFORE_LOCK              | Перед `lock()`
 11   | AFTER_LOCK               | После `lock()`
 12   | BEFORE_SYNC              | Перед `sync()`
 13   | AFTER_SYNC               | После `sync()`


