/* Функции для работы с БД  */

function ConnStr()// строки подключения к БД. пока только для Оракла
{

 this.GetConStr = function (bd_name)
 {
  switch(bd_name) //Если много БД, то добавить сюда ещё case'ов
    {
 
     case "Ora":
      return ("Provider=MSDAORA.1;Password=;User ID=;Data Source=" + bdName  + ";Persist Security Info=True;Database ="  + bdName);
    };
  }; 
}

function GetDataFromDB(srv, txtSQLcommand) //Возвращает результаты запроса в виде массива(двумерного) все равно потом нужна будет!!!!
{
  var Query;
  var arrReturn = new Array();
  var CnnStr = new ConnStr();

  Query = ADO["CreateADOQuery"]();
  Query["ConnectionString"] = CnnStr.GetConStr(srv); // сдесь должна быть строка конекта :)
  Query["SQL"] = txtSQLcommand;
  Query["Open"]();
//  Query["First"]();
  var k = 0;
  while (!Query["EOF"])
  {
        var arrEl = new Array();
        for (var i = 0; i < Query["FieldCount"]; i++)
          {
           arrEl[i] = Query["Field"](i)["Value"];
          }
        arrReturn[k] = arrEl;
        k++;
        Query["Next"]();
  }

  Query["Close"]();
  
  return arrReturn;

//как потом получить назад данные
//var arr = new Array();
//arr= GetDataFromDB(txtSQL); // получяаете двумерный массив
//var g = arr[0][1] // вот так можно добираться елементов массива
//    
}


