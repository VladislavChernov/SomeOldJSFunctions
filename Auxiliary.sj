/******************************************************************************
            Вспомогательные(общие) функции
******************************************************************************/

function WaitWin(parent, caption) //ждалка окошка через Родителя
{
 var cnt = 0;
 
 while(!parent.WaitWindow("*", caption, -1, 700).Exists)
  {
      aqUtils.Delay(1000);
    cnt++;
    if(cnt == 20)
      {
        Log.Message("Нужное окно не появилось в течении 1 минуты");
        return false;
      }    
  } 
 return parent.WaitWindow("*", caption, -1, 1);    
}

function waitWnd(wnd, interval, params)//ждалка окна  через функцию получения окна
//В качестве параметра передаем функцию, которое ищет нужное нам окошко.
// interval - частота проверки в секундах на предмет существавания элемента. по умолчанию 1с
// params   - параметры ждалки окна, это если мы ждем какое-то конкретное окно, а не стандартную возвращалку чего либо 
{
  interval = interval || 1;
  var i = 0;
  while(!wnd(params).Exists)
    {
      aqUtils.Delay(interval * 1000); // ждем 1с.
      i++;
      if(60 == i)
        {
          return false;
        } 
      wnd(params);   
    }
  
  return wnd(params);      
}

function GetBrowser() //Возвращаем из ОДТ тип браузера(объект)
{
  var browser = ODT.Data.Init._browser;

  switch(browser){
    case "Firefox" : {
      return Browsers.Item(btFirefox);
      break;
    }
    case "Opera" : {
      return Browsers.Item(btOpera);
      break;
    }
    case "Safary" : {
      return Browsers.Item(btSafari);
      break;
    }
    case "Chrome" : {
      return Browsers.Item(btChrome);
      break;
    }
    default : {
      return Browsers.Item(btIExplorer);
    }
  }    
}

function GetStartPage() //Возвращает стартовую страницу.
{
  return ODT.Data.Init._logonPage;
}

function fndField(PropArr, ValArr, dept)  //Получение чего либо по его свойствам (в принцыпе старая функция)
/*****************************************************************************
  Функция, которая возвращает поле/страницу/объект, по его свойствам.
  Параметры:
  PropArr - строковый массив имен свойств. Например, "Caption"
  ValArr  - строковый массив значений свойств. Например, "Пустая страница*"
  номер имени свойства и номер значения свойства в соответствующих массивах дожны быть одинаковые.
  dept - глубина вложенности этого поля/страницы/объекта относительно его родителя.
         можно не задавать. нужно для ускорения поиска элемента страницы. по умолчанию 20
******************************************************************************/  
{
 var fld; // тут будем хранить найденное

 dept = dept || 20; //Уровень вложенности по умолчанию 
 fld  = Sys.Browser(ODT.Data.Init._browserName).FindChild(PropArr, ValArr, dept, true);
  
 if (fld.Exists)
    return fld;

// Log.Error("Неверно выбранны параметры поля для поиска."); //для отладки.
 return false;  
}

function FillField(fld, val) //Заполняем поле и жмем табулятор на его папе.
{
  if(aqString.Find(aqString.ToLower(val), "check") != -1 || aqString.Find(aqString.ToLower(val), "uncheck") != -1)
    fld.Checked = (!(aqString.Find(aqString.ToLower(val), "uncheck") != -1));
  else  
	fld.Keys("[End]![Home]" + val + "[Enter][Tab]");
}

function GetChildren(obj, cType, cVal, dept, isEnabled) //возвращает всех детей на глубину dept
/*
*  Входные параметры:
*  obj       - элемент от которого будем искать детей
*  cType     - название свойства по которому ищем, например ObjectType
*  cVal      - значение cType, например Panel
*  dept      - глубина поиска. по дефолту ставлю в 5.
*  isEnabled - искать или нет серенькие(grayedout) элементы. по умолчанию не искать. в большинстве случаев они не нужны.
*    
*  Вестимо, что ищутся ТОЛЬКО ВИДИМЫЕ элементы.
*/
{
  
  dept = dept || 5; // глубина небольшая. поэтому 5
  cType = cType || "";
  isEnabled = isEnabled || true;
  
  var cldObj; // Тут будем хранить найденый детей
  
  var PropArray = new Array("Visible", /*"Enabled",*/ "Exists");
  var ValuesArray = new Array(true, /*"True",*/ true);
  
  if(isEnabled)
    {
      PropArray = PropArray.concat("Enabled");
      ValuesArray = ValuesArray.concat(isEnabled); 
    }
  
  if(cType != "")
    {
      PropArray = PropArray.concat(cType);
      ValuesArray = ValuesArray.concat(cVal);    
    }
  
  obj.Refresh();
  
  cldObj = obj.FindAllChildren(PropArray, ValuesArray, dept);
  cldObj = VBArray(cldObj).toArray();
  
//  Log.Message("from GetChildren = " + cldObj.length); //для отладки
  return cldObj;
}

function GetChild(obj, cType, cVal, dept) //возвращает ОДНОГО потомка на глубину dept
/*
  Входные параметры:
  obj   - элемент от которого будем искать потомка
  cType - название свойства по которому ищем, например ObjectType
  cVal  - значение cType, например Panel
  dept  - глубина поиска. по дефолту ставлю в 5.
*/
{
  dept = dept || 5; // глубина небольшая. поэтому 5
  
  if(!obj.Exists)
    return {Exists : false}; 
  
  var cldObj; // Тут будем хранить найденый детей
  
  var PropArray = new Array("Visible", "Enabled", "Exists");
  var ValuesArray = new Array("True", "True", "True");
  
  PropArray = PropArray.concat(cType);
  ValuesArray = ValuesArray.concat(cVal);
  
  obj.Refresh();
  
  cldObj = obj.FindChild(PropArray, ValuesArray, dept);

  if(cldObj.Exists)
    return cldObj;
  
  return {Exists : false};    
}