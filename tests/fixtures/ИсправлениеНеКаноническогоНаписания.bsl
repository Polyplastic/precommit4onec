#Область ХорошихПеременных
Перем пер1
#КонецОбласти

#область ПлохихПеременных

ПЕРЕМ пер1;
перем пер3;
//ПEрем пер4
// ПEрем пер5
Перем пер6; //если тут будет текст его не заменит 


#КонецОБласти

&НаКлиентенаСервере
ПРоцедура тест()
конецпроцедуры

&Насервере
процедура СКомментарием() // Комментарий
КонецПроцедуры

&Наклиенте
функция ТестовыйУжас(ЗНАЧ пар)
	#если КлиенТ ИЛИ сервер #тогда
	перейти МеткаВыход :
	#Конецесли
	
	если истина тогда Сообщить(не(ложь и null=НеОпределено)); возврат Неопределено; иначе конецесли;
	
	пока п1 = п2 цикл // если тогда иначе конецесли;
		прервать;
	конеццикла;
	
	Если ИСТИНА Тогда
		Сообщить();
	иначеЕсли ЛОЖЬ Тогда
		попытка
			Переменная1 = новый Массив;
		исключение
			вызватьИсключение "сложно набирать такой код"
		конецпопытки;
		
	КонецЕсли;
	
	#Если НЕ вебклиент и не Тонкийклиент ИЛИ ТолстыйКлиентОбычноеприложение ИЛИ толстыйКлиентУправляемоеПриложение ИЛИ ВнешнееСоединение
	
	#КонецЕсли
	
	для каждого Элемент из Переменная1 Цикл
	выполнить("Сообщить(""Привет"")");
	КонецЦикла;
	
	Для i = 1 по 10 Цикл
	КонецЦикла;
	
	Соообщить("тут пример однострочника");добавитьОбработчик Накладная.ПриЗаписи Обработка.ПриЗаписиДокумента;Удалитьобработчик Накладная.ПриЗаписи, Обработка.ПриЗаписиДокумента;
	Возврат ?(истина=истина,ложь,истина);
конецфункции

&НасерверебезКонтекста
Процедура тест(Пар1,
	Пар2,
	ЗНАЧ пар3)// Комментарий
КонецПроцедуры

&наКлиентеНаСервереБезКонтекста
Процедура тест() // Комментарий
КонецПроцедуры

&наКлиентенаСервере
Процедура тест() // Комментарий
КонецПроцедуры