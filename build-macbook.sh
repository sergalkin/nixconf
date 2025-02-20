#!/bin/bash

# Скрипт для сборки конфигурации MacBook
# Запускает darwin-rebuild и home-manager для применения системных и пользовательских настроек

# Шаг 1: Сборка системной конфигурации nix-darwin
# Команда применяет darwin/macbook.nix и модули из flake.nix (включая nix-homebrew)
echo "Сборка системной конфигурации для MacBook..."
darwin-rebuild switch --flake .#macbook

# Проверка успешности выполнения
if [ $? -eq 0 ]; then
    echo "Системная конфигурация успешно применена."
else
    echo "Ошибка при сборке системной конфигурации!"
    exit 1
fi

# Шаг 2: Сборка пользовательской конфигурации Home Manager
# Применяет home/home.nix для пользователя Siv
echo "Сборка пользовательской конфигурации Home Manager..."
home-manager switch --flake .#ser

# Проверка успешности выполнения
if [ $? -eq 0 ]; then
    echo "Пользовательская конфигурация успешно применена."
else
    echo "Ошибка при сборке пользовательской конфигурации!"
    exit 1
fi

echo "Сборка MacBook завершена!"
