﻿&НаСервере
Функция ВыполнитьЗапрос()
	
		
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	1 КАК ВидДокумента,
	|	Док.Дата КАК Дата,
	|	Док.Ссылка КАК Ссылка,
	|	Док.Организация,
	|	Док.Контрагент,
	|	NULL КАК ДокументОтгрузки
	|ИЗ
	|	Документ.РеализацияТоваровУслуг КАК Док
	|ГДЕ
	|	НЕ Док.ПометкаУдаления
	|	И ВЫБОР
	|			КОГДА &ЕстьДатаНач
	|				ТОГДА Док.Дата >= &ДатаНач
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ЕстьДатаКон
	|				ТОГДА Док.Дата <= &ДатаКон
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ЕстьОрганизация
	|				ТОГДА Док.Организация = &Организация
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	2,
	|	Док.Дата,
	|	Док.Ссылка,
	|	Док.Организация,
	|	NULL,
	|	Док.ДокументОтгрузки
	|ИЗ
	|	Документ.РеализацияОтгруженныхТоваров КАК Док
	|ГДЕ
	|	НЕ Док.ПометкаУдаления
	|	И ВЫБОР
	|			КОГДА &ЕстьДатаНач
	|				ТОГДА Док.Дата >= &ДатаНач
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ЕстьДатаКон
	|				ТОГДА Док.Дата <= &ДатаКон
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ЕстьОрганизация
	|				ТОГДА Док.Организация = &Организация
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ";	
	
	Запрос.УстановитьПараметр("ЕстьДатаНач", ЗначениеЗаполнено(Период.ДатаНачала));
	Запрос.УстановитьПараметр("ДатаНач", Период.ДатаНачала);
	Запрос.УстановитьПараметр("ЕстьДатаКон", ЗначениеЗаполнено(Период.ДатаОкончания));
	Запрос.УстановитьПараметр("ДатаКон", Период.ДатаОкончания);
	
	Запрос.УстановитьПараметр("ЕстьОрганизация", ЗначениеЗаполнено(Организация));
	Запрос.УстановитьПараметр("Организация", Организация);
	
	
	Возврат Запрос.Выполнить();
	
	
КонецФункции

&НаСервере
Процедура ВыполнитьДопроведениеНаСервере()
	
	РезультатЗапроса = ВыполнитьЗапрос();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Отказ = Ложь;
		РежимПроведения = РежимПроведенияДокумента.Неоперативный;
		
		
		//вместо объекта документа будем передавать туда структуру, чтобы не выполнять чтение через точку в цикле
		Источник = Новый Структура;
		Источник.Вставить("Дата", Выборка.Дата);
		Источник.Вставить("Ссылка", Выборка.Ссылка);
		Источник.Вставить("Организация", Выборка.Организация);
		
		Если Выборка.ВидДокумента = 1 Тогда
			
			Источник.Вставить("Контрагент", Выборка.Контрагент);
			
		ИначеЕсли Выборка.ВидДокумента = 2 Тогда
			
			Источник.Вставить("ДокументОтгрузки", Выборка.ДокументОтгрузки);
			
		КонецЕсли;
		
		
		ДЭТК_ОбщийМодуль1.ДЭТК_ПроведениеРеализацииОбработкаПроведения(Источник, Отказ, РежимПроведения);
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьДопроведение(Команда)
	ВыполнитьДопроведениеНаСервере();
	//Предупреждение("Обработка завершена!");
	
КонецПроцедуры

