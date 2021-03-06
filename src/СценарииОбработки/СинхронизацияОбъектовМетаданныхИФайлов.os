///////////////////////////////////////////////////////////////////////////////
// 
// Служебный модуль с реализацией сценариев обработки файлов <СинхронизацияОбъектовМетаданныхИФайлов>
//
///////////////////////////////////////////////////////////////////////////////

// ИмяСценария
//	Возвращает имя сценария обработки файлов
//
// Возвращаемое значение:
//   Строка   - Имя текущего сценария обработки файлов
//
Функция ИмяСценария() Экспорт
	
	Возврат "СинхронизацияОбъектовМетаданныхИФайлов";
	
КонецФункции // ИмяСценария()

// ОбработатьФайл
//	Выполняет обработку файла
//
// Параметры:
//  АнализируемыйФайл		- Файл - Файл из журнала git для анализа
//  КаталогИсходныхФайлов  	- Строка - Каталог расположения исходных файлов относительно каталог репозитория
//  ДополнительныеПараметры - Структура - Набор дополнительных параметров, которые можно использовать 
//  	* Лог  					- Объект - Текущий лог
//  	* ИзмененныеКаталоги	- Массив - Каталоги, которые необходимо добавить в индекс
//		* КаталогРепозитория	- Строка - Адрес каталога репозитория
//		* ФайлыДляПостОбработки	- Массив - Файлы, изменившиеся / образовавшиеся в результате работы сценария
//											и которые необходимо дообработать
//
// Возвращаемое значение:
//   Булево   - Признак выполненной обработки файла
//
Функция ОбработатьФайл(АнализируемыйФайл, КаталогИсходныхФайлов, ДополнительныеПараметры) Экспорт
	
	Лог = ДополнительныеПараметры.Лог;
	НастройкиСценария = ДополнительныеПараметры.Настройки.Получить(ИмяСценария());
	Если АнализируемыйФайл.Существует() И ТипыФайлов.ЭтоФайлОписанияКонфигурации(АнализируемыйФайл) Тогда
		
		Лог.Информация("Обработка файла '%1' по сценарию '%2'", АнализируемыйФайл.ПолноеИмя, ИмяСценария());
		
		Если СинхронизироватьМетаданныеиФайлы(АнализируемыйФайл.ПолноеИмя, ДополнительныеПараметры.ИзмененныеКаталоги) Тогда
			
			ДополнительныеПараметры.ИзмененныеКаталоги.Добавить(АнализируемыйФайл.ПолноеИмя);
			
		КонецЕсли;
		
		Возврат Истина;
		
	КонецЕсли;
	
	Возврат ЛОЖЬ;
	
КонецФункции // ОбработатьФайл()

Функция СинхронизироватьМетаданныеиФайлы(Знач ИмяФайла, УдаленныеФайлы)
	
	СодержимоеФайла = ФайловыеОперации.ПрочитатьТекстФайла(ИмяФайла);
	Регексп = Новый РегулярноеВыражение("(<ChildObjects>\s+?)([\w\W]+?)(\s+<\/ChildObjects>)");
	Регексп.ИгнорироватьРегистр = ИСТИНА;
	Регексп.Многострочный = ИСТИНА;
	ПодчиненныеМетаданные = Регексп.НайтиСовпадения(СодержимоеФайла);
	Если ПодчиненныеМетаданные.Количество() = 0 Тогда
		
		Возврат Ложь;	
		
	КонецЕсли;
	
	ИсходнаяСтрока = ПодчиненныеМетаданные[0].Группы[2].Значение;
	РегекспМетаданные = Новый РегулярноеВыражение("^\s+<([\w]+)>([а-яa-zA-ZА-Я0-9_]+)<\/[\w]+>");
	РегекспМетаданные.ИгнорироватьРегистр = ИСТИНА;
	РегекспМетаданные.Многострочный = Истина;
	ОбъектыМетаданныхСтроки = РегекспМетаданные.НайтиСовпадения(ИсходнаяСтрока);
	
	ОбъектыМетаданных = Новый ТаблицаЗначений;
	ОбъектыМетаданных.Колонки.Добавить("ТипМетаданных");
	ОбъектыМетаданных.Колонки.Добавить("ИмяМетаданных");
	Для Каждого ОбъектМетаданных Из ОбъектыМетаданныхСтроки Цикл
		
		НоваяЗапись = ОбъектыМетаданных.Добавить();
		НоваяЗапись.ТипМетаданных = ОбъектМетаданных.Группы[1].Значение;
		НоваяЗапись.ИмяМетаданных = ОбъектМетаданных.Группы[2].Значение;
		
	КонецЦикла;
	
	ОбъектыМетаданных.Свернуть("ТипМетаданных, ИмяМетаданных", "");
	
	СписокКаталогов = СписокКаталоговТиповМетаданных();
	КорневойПуть = Новый Файл(ИмяФайла);
	КорневойПуть = КорневойПуть.Путь;
	СписокДляУдаления = Новый СписокЗначений;
	ЕдиныйТекстОшибки = "";
	Для Каждого КаталогИзСписка Из СписокКаталогов Цикл
		
		ОбъектыМетаданныхТипа = ОбъектыМетаданных.НайтиСтроки(Новый Структура("ТипМетаданных", КаталогИзСписка.Представление));
		
		Каталог = Новый Файл(ОбъединитьПути(КорневойПуть, КаталогИзСписка.Значение));
		Если НЕ Каталог.Существует() Тогда
			
			Если ОбъектыМетаданныхТипа.Количество() Тогда
			
				// каталога нет,  а должен быть
				ЕдиныйТекстОшибки = ЕдиныйТекстОшибки + ?(ПустаяСтрока(ЕдиныйТекстОшибки), "", Символы.ПС) + "Отсутствует каталог " + КаталогИзСписка.Значение;
				
			КонецЕсли;

			Продолжить;
			
		КонецЕсли;
		
		// Если типа метаданных нет, то просто удаляем каталог
		Если НЕ ОбъектыМетаданныхТипа.Количество() Тогда
			
			СписокДляУдаления.Добавить(Каталог.ПолноеИмя);
			Продолжить;
			
		КонецЕсли;
		
		// Проверка содержимого каталога
		ВсеФайлыОбъектовТипа = НайтиФайлы(Каталог.ПолноеИмя, "*.xml");
		НадоПропустить = Новый Массив;
		Для Каждого ФайлОбъектаТипа Из ВсеФайлыОбъектовТипа Цикл
			
			Если НадоПропустить.Найти(ФайлОбъектаТипа.ИмяБезРасширения) <> Неопределено Тогда
				Продолжить;
			КонецЕсли;
			
			НадоПропустить.Добавить(ФайлОбъектаТипа.ИмяБезРасширения);
			
			СуществующиеОбъекты = ОбъектыМетаданных.НайтиСтроки(Новый Структура("ТипМетаданных, ИмяМетаданных", КаталогИзСписка.Представление, ФайлОбъектаТипа.ИмяБезРасширения));
			Если СуществующиеОбъекты.Количество() Тогда
				
				Для Каждого УдаляемаяСтрока Из СуществующиеОбъекты Цикл
					
					ОбъектыМетаданных.Удалить(УдаляемаяСтрока);
					
				КонецЦикла;

				Продолжить;
				
			КонецЕсли;
			
			// остатки файлов надо удалить
			СписокДляУдаления.Добавить(ФайлОбъектаТипа.ПолноеИмя);
			ФайлОбъектаТипаКаталог = Новый Файл(ОбъединитьПути(Каталог.ПолноеИмя, ФайлОбъектаТипа.ИмяБезРасширения));
			СписокДляУдаления.Добавить(ФайлОбъектаТипаКаталог.ПолноеИмя);
			
		КонецЦикла;

		ВсеФайлыОбъектовТипа = НайтиФайлы(Каталог.ПолноеИмя, "*");
		Для Каждого ФайлОбъектаТипа Из ВсеФайлыОбъектовТипа Цикл
			
			Если НЕ ФайлОбъектаТипа.ЭтоКаталог() Тогда
				
				Продолжить;
				
			КонецЕсли;

			Если НадоПропустить.Найти(ФайлОбъектаТипа.ИмяБезРасширения) <> Неопределено Тогда
				Продолжить;
			КонецЕсли;
			
			// остатки файлов надо удалить
			СписокДляУдаления.Добавить(ФайлОбъектаТипа.ПолноеИмя);
			
		КонецЦикла;
	
	КонецЦикла;

	МассивИсключенийМетаданных = ПолучитьМассивИсключенийМетаданных();

	// проверка наличия объектов, для которых нет каталогов
	Если ОбъектыМетаданных.Количество() Тогда
				
		Для Каждого ОбъектМетаданных Из ОбъектыМетаданных Цикл
			
			Если МассивИсключенийМетаданных.Найти(ОбъектМетаданных.ТипМетаданных) <> Неопределено Тогда 
			
				Продолжить;
			
			КонецЕсли;

			ЕдиныйТекстОшибки = ЕдиныйТекстОшибки + ?(ПустаяСтрока(ЕдиныйТекстОшибки), "", Символы.ПС) 
				+ "Отсутствуют файлы для " + ОбъектМетаданных.ТипМетаданных + "." + ОбъектМетаданных.ИмяМетаданных;

		КонецЦикла;
	
	КонецЕсли;

	Для Каждого ФайлДляУдаления Из СписокДляУдаления Цикл
		
		ЕдиныйТекстОшибки = ЕдиныйТекстОшибки + ?(ПустаяСтрока(ЕдиныйТекстОшибки), "", Символы.ПС) 
				+ "Необходимо удалить файлы " + ФайлДляУдаления.Значение;
		
	КонецЦикла;
	
	Если НЕ ПустаяСтрока(ЕдиныйТекстОшибки) Тогда
		
		ВызватьИсключение ЕдиныйТекстОшибки;
		
	КонецЕсли;

	Возврат Истина;
	
КонецФункции

Функция ПолучитьМассивИсключенийМетаданных() 
	
	МассивИсключений = Новый Массив();
	МассивИсключений.Добавить("Sequence");
	
	Возврат МассивИсключений;
	
КонецФункции

Функция СписокКаталоговТиповМетаданных()
	
	Список = Новый СписокЗначений();
	Список.Добавить("AccumulationRegisters", "AccumulationRegister");
	Список.Добавить("BusinessProcesses", "BusinessProcess");
	Список.Добавить("Catalogs", "Catalog");
	Список.Добавить("ChartsOfCalculationTypes", "ChartOfCalculationTypes");
	Список.Добавить("ChartsOfCharacteristicTypes", "ChartOfCharacteristicTypes");
	Список.Добавить("CalculationRegisters", "CalculationRegister");
	Список.Добавить("CommandGroups", "CommandGroup");
	Список.Добавить("CommonAttributes", "CommonAttribute");
	Список.Добавить("CommonCommands", "CommonCommand");
	Список.Добавить("CommonForms", "CommonForm");
	Список.Добавить("CommonModules", "CommonModule");
	Список.Добавить("CommonPictures", "CommonPicture");
	Список.Добавить("CommonTemplates", "CommonTemplate");
	Список.Добавить("Constants", "Constant");
	Список.Добавить("DataProcessors", "DataProcessor");
	Список.Добавить("DefinedTypes", "DefinedType");
	Список.Добавить("DocumentJournals", "DocumentJournal");
	Список.Добавить("DocumentNumerators", "DocumentNumerator");
	Список.Добавить("Documents", "Document");
	Список.Добавить("Enums", "Enum");
	Список.Добавить("EventSubscriptions", "EventSubscription");
	Список.Добавить("ExchangePlans", "ExchangePlan");
	Список.Добавить("FilterCriteria", "FilterCriterion");
	Список.Добавить("FunctionalOptions", "FunctionalOption");
	Список.Добавить("FunctionalOptionsParameters", "FunctionalOptionsParameter");
	Список.Добавить("HTTPServices", "HTTPService");
	Список.Добавить("InformationRegisters", "InformationRegister");
	Список.Добавить("Languages", "Language");
	Список.Добавить("Reports", "Report");
	Список.Добавить("Roles", "Role");
	Список.Добавить("ScheduledJobs", "ScheduledJob");
	Список.Добавить("SessionParameters", "SessionParameter");
	Список.Добавить("SettingsStorages", "SettingsStorage");
	Список.Добавить("StyleItems", "StyleItem");
	Список.Добавить("Sequences", "Sequence");
	Список.Добавить("Styles", "Style");
	Список.Добавить("Subsystems", "Subsystem");
	Список.Добавить("Tasks", "Task");
	Список.Добавить("WebServices", "WebService");
	Список.Добавить("WSReferences", "WSReference");
	Список.Добавить("XDTOPackages", "XDTOPackage");
	Список.Добавить("ExternalDataSources", "ExternalDataSource");
	Список.Добавить("ChartsOfAccounts", "ChartOfAccounts");
	Список.Добавить("AccountingRegisters", "AccountingRegister");
	Возврат Список;
	
КонецФункции
