local constants =
{
    -- Глобальные пожелания бота, что делать
    globalBotDesire =
    {
        LANING = 1, -- Получать золото на линии
        ROSHAN = 2, -- Убить Рошана
        ROUMING = 3, -- Искать пользу на карте, для себя или союзников
        FARMING = 4,     -- Фармить (нейтралы или линия)
        PUSHING = 5      -- Пушить линии
    },
    --Желания бота при фарме на линии
    laningBotDesire =
    {
        MOVING_TO_LINE = 1, -- Отправка на линию
        LASTHIT_CRREP = 2, -- Добивание крипов для получения золота и опыта
        ENEMY_HERO_HARAS = 3, -- Нанесение урона вражескому герою
        RETREATING_ON_LINE = 4, -- Отступление назад по линии в случае опасности
        RESTORING_HP = 5, -- Восстановление здоровья (ХП)
        RESTORING_MANA = 6 -- Восстановление маны для использования способностей
    },
    
    --Константы для расшифровки статуса покупки предмета
    purchaseStatus = 
    {
        [PURCHASE_ITEM_SUCCESS] = "Покупка успешна",
        [PURCHASE_ITEM_OUT_OF_STOCK] = "Предмет отсутствует на складе",
        [PURCHASE_ITEM_DISALLOWED_ITEM] = "Предмет не разрешен",
        [PURCHASE_ITEM_INSUFFICIENT_GOLD] = "Недостаточно золота",
        [PURCHASE_ITEM_NOT_AT_HOME_SHOP] = "Не в домашнем магазине",
        [PURCHASE_ITEM_NOT_AT_SIDE_SHOP] = "Не в боковом магазине",
        [PURCHASE_ITEM_NOT_AT_SECRET_SHOP] = "Не в секретном магазине",
        [PURCHASE_ITEM_INVALID_ITEM_NAME] = "Неверное имя предмета"
    }
}


return constants