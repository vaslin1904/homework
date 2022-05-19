# **Описание репозитория homework**

В этом репозитории будут выложены
домашние работы с указанием соответствующего номера темы курса.

_______________________________________________________________________________________
Создание удаленного репозитория.
________________________________________________________________________________________
1. Создаем локальный репозиторий homework, в котором и будут размещаться домашние работы.
	- в локальной директории создается одноименная папка "homework". Перехоим в эту папку.
	- В командной строке инициализируем новый локальный репозиторий: git init.
	Результат команды: Initialized empty Git repository in N:/Linux ot/Git repo/homework/.git/
	- По умолчанию в локальном репозитории главная ветка называется master, а в удаленном репозитории - main.
  	 Переименуем главную ветку локального репозитория в main:
	- Создаем текстовый файл для нового репозитория и добавляем его в него: README.md.
2. Добавляем папку, содержащую результат выполнения домашней работы 1:git add work1_kernel
3. Закрепляем внесенные изменения в наш репозиторий с помощью добавления комментария в текстовом редакторе vi: git commit -a
	Комментарий можно добавить из командной строки: git commit -m "edit .md".
4. Добавляем данные об авторе репозитория в комментарии: git config --global user.name "Galkina Ekaterina"
   Просмотр настроек конфигурационного файла .config: git config --list
   Просмотр местонахождение настроек git: git config --list --show-origin
	Проверить состояние репозитория - git status
________________________________________________________________________________________
Слияние локального репозитория с удаленным
________________________________________________________________________________________

1. Пропишем в локальном репозитории адрес удаленного: git remote add origin https://github.com/vaslin1904/homework.git
2. Синхронизируем локальный репозиторий с удаленным:git push.
	
	
	       
