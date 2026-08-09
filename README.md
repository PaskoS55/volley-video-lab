# VOLLEY VIDEO LAB — Prototype 0.0.1

Технический прототип Desktop-first видеоанализатора для волейбола.

## Уже реализовано

- открытие локального видео;
- Play/Pause;
- ±5 секунд;
- прототип покадрового шага;
- 0.5× / 1×;
- Source Time;
- Review Time;
- REC-сессия;
- логирование play/pause/seek/speed/frame-step;
- рисование поверх видео;
- стрелки;
- окружность игрока;
- Undo / Clear;
- сохранение Review Events в JSON.

## Пока не реализовано

- реальная запись микрофона;
- воспроизведение Review Events как готовой сессии;
- точное определение FPS видео;
- libmpv;
- Freeze / Instant Replay;
- тактическая доска;
- SQLite;
- экспорт MP4;
- AI.

## Требования

- Qt 6.5+ с модулями Core, Gui, Qml, Quick, Multimedia, QuickControls2
- CMake 3.21+
- C++17 compiler

## Сборка

```bash
cmake -S . -B build
cmake --build build --config Release
```

## Первый технический тест

1. Открыть 50/60 fps волейбольный MP4.
2. Нажать REC.
3. Проиграть 5 секунд.
4. Pause.
5. Нарисовать окружность и стрелку.
6. Play.
7. −5 секунд.
8. Переключить 0.5×.
9. STOP.
10. Сохранить Review JSON и проверить последовательность событий.

## Следующий шаг

Prototype 0.0.2 должен добавить:

- QAudioSource/QMediaRecorder для записи микрофона;
- точный media FPS через FFprobe;
- Review Playback Engine;
- Freeze;
- Instant Replay;
- JSON project format `.vvl`.
