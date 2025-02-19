# Case-study оптимизации

## Актуальная проблема
В нашем проекте возникла серьёзная проблема.

Необходимо было обработать файл с данными, чуть больше ста мегабайт.

У нас уже была программа на `ruby`, которая умела делать нужную обработку.

Она успешно работала на файлах размером пару мегабайт, но для большого файла она работала слишком долго, и использовала для работы несколько гигабайт оперативной памяти.

Я решил исправить эту проблему, оптимизировав эту программу.

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы я придумал использовать такую метрику:
* общее время выполнения программы
* память которую занимала программа в конце выполнения 


## Гарантия корректности работы оптимизированной программы
Программа поставлялась с тестом. Выполнение этого теста в фидбек-лупе позволяет не допустить изменения логики программы при оптимизации.

## Feedback-Loop
Для того, чтобы иметь возможность быстро проверять гипотезы я выстроил эффективный `feedback-loop`, который позволил мне получать обратную связь по эффективности сделанных изменений за несколько секунд

Вот как я построил `feedback_loop`: 
- прогон тестов после изменений через тесты в отдельном файле task-2_spec.rb чтобы убедиться что изменения не сломали логику программы
- прогон программы на большой объеме через её запуск из отдельного файла app.rb чтобы увидеть общее время работы и потребляемую память

## Вникаем в детали системы, чтобы найти главные точки роста
Для того, чтобы найти "точки роста" для оптимизации я воспользовался *инструментами, которыми вы воспользовались*

Вот какие проблемы удалось найти и решить

### Ваша находка №1
- Для начала я обратил внимание на то что программа читает весь файл целиком, производит вычисления на полном объеме данных, а потом целиком выгружает результат в файл 
- Поэтому было решено переписать её в потоковом стиле что сторочка за строчкой формировать отчет, и по возможности сохранять результаты в файл 
- Время выполнения перестало уходить в часы, а занимаемая память в конце выполнения стала немного больше минимальных для ruby 13 мб  что говорит об её высвобождении  
  MEMORY USAGE: 14 MB
  Finish in 12.59
- профилировщик пока не запускал

### Ваша находка №2
- MemoryProfiler показал что всего аллоцированно 14.81MB из них больше всего 4.3MB памяти выделяется  на 50й строке где мы делаем `line.split(','')` 
- нам в любом случае придется это делать для сессий, и частично для юзеров, но здесь это выглядит лишним, потому что используется только чтобы определить юзер в строке или сессия, поэтому убираю `split`  и использую в проверке `start_with?`
- метрика по памяти не изменилась, а время выполнения немного уменьшилось
  MEMORY USAGE: 14 MB
  Finish in 11.69
- MemoryProfiler стал показывать что всего аллоцированно 10.47MB  50я строка ушла из топа, а также уменьшилась выделяемая массивам и строкам память

### Ваша находка №X
- MemoryProfiler показал что всего аллоцированно 10.47MB из них больше всего 3.7MB памяти выделяется  на 13й строке где мы делаем `line.split(','')` при парсинге сессий
- На ум приходит делать потоковым чтение каждой строки. т.е. читать строку пока не встречу `,` делать над этой подстрокой вычисления и идти читать до следующей запятой.
  Но предыдущие оптимизации показали что ниже порога 14mb опуститься не выйдет, а мои эксперименты над пустой руби программой показали что ниже 13mb программа не может занимать
  Поэтому оставляю код как есть, чтобы не повредить её читаемости(но я не сдался =))
- если все же сделать изменения выше метрики останутся примерно такие же
  MEMORY USAGE: 14 MB
  Finish in 11.93
- Из топа ушел split при парсинге сессий, в топ вышла строка читающая файл, а на втором месте парсинг юзеров

## Результаты
В результате проделанной оптимизации наконец удалось обработать файл с данными.
Большой файл удалось распарсить за 12 секунд, и занимая в конце 14mb памяти.
valgrind  показал такую картину. до правок показывал 700+ и продолжала расти
![img.png](img.png)

* Пришел к выводу что ниже 13mb программа на руби не может занимать.
* Что каждый лишний require увеличивает эту цифру 
* Из профайлеров мне больше всего полюбился MemoryProfiler и stackprof

## Защита от регрессии производительности
Для защиты от потери достигнутого прогресса при дальнейших изменениях программы написан тест ограничивающий потребляемую память при выполнении файла на 10_000 строк(теста правда получился очень чувствительный к окружающим тестам, и потому в реальной работе не особо применимый)
