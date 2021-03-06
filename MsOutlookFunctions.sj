//USEUNIT Auxiliary

function isMessageReceived2010(accountName, senderEMail, eMailSubject) //просто сэмпл со свясик разным
{
  var OutlookApplication = Sys.OleObject("Outlook.Application");  
  var NamespaceMAPI = OutlookApplication.GetNamespace("MAPI"); 
  var abc=NamespaceMAPI.Accounts.Item(1);

  // Check whether the specified account exists:

  if(NamespaceMAPI.Accounts.Item(accountName) != null)
    {
      NamespaceMAPI.SendAndReceive(false);
      var targetfolder="c:/";

  // Get the "Inbox" folder 

      var inbox = NamespaceMAPI.Folders(accountName).Folders("Inbox");
  //get all mail items and store it in a variable

      var items = inbox.Items; 
      aqFile.WriteToTextFile("c:/sample/abc.txt",items.Count,aqFile.ctUTF8);

   //traversing through the mail items
      for(var i = items.Count; i >= 1; i--)
        {
  //get the mail subject
          aqString.Trim(items.Item(i).Subject,aqString.stAll);

  //you can also get any other details on mail, as required 
          aqString.Trim(items.Item(i).SenderEmailAddress,aqString.stAll);

          if(items.Item(i).Subject == eMailSubject) 
            {
  //get the number of attachments that come with the expected mail
            aqFile.WriteToTextFile("c:/sample/abc.txt",items.Item(i).Attachments.Count,aqFile.ctUTF8);

            var myItem=items.Item(i);

            if(myItem.Attachments.Count>0)
              { 
                aqFile.WriteToTextFile("c:/sample/abc.txt","do i have attachments,my count is "+ myItem.Attachments.Count,aqFile.ctUTF8);
 
  //get the attachment name and print it 
               attachmentName=myItem.Attachments.Item(1);
               aqFile.WriteToTextFile("c:/sample/abc.txt","my attachment name" + attachmentName,aqFile.ctUTF8);
 
  //save your attachment in the preferred path and preferred format
               attachment.SaveAsFile("c:/sample/as.pdf");
   /* Now, in case if the attachment has to be compared with an other item, use TestComplete checkpoint concept, by storing the base lined document in stores compare it with the attachment that is downloaded from mail – u r done! */
               Files.PDS_IAL_SGIO_pdf.Check("C:\\sample\\as.pdf"); 
               return true;
             }
         } 
    }

  return false;

  } else
    {
      OutlookApplication.Quit();
      return false;
    }
}

function getOleOutlook() //Получаем OLE объект для аутлука
{
  return Sys.OleObject("Outlook.Application").GetNamespace("MAPI");
}

function getUnreadMail(otlAccount, sender)//Получаем массив непрочитанных писем от известного нам оправителя
/*
*
*         Входные данные:
*     otlAccount - почтовый адрес получателя писем рассылки(т.е. того кто запускает скрипты)
*     sender     - почтовый адрес того, кто отправляет письма (т.е. самого ГС)
*
*/

{
 otlAccount = otlAccount || //TODO: сюда вбить e-mail адрес того, чью почту проверяем
 sender = sender || //TODO: сюда вбить почтовый адрес отправителя 
 
 var i, cnt;
 var mItems = {};  //тут будем хранить наши письма.
 var otlObjs; // просто обьекты отутгюковские
 var flds = [3, 11]; //Папки в Аутглюке 3 - Inbox, 11 - Spam
 
 otlObjs = getOleOutlook().Folders(otlAccount);
 //Ищем непрочитанные письма по папкам:
  
 for(cnt = 0; cnt < flds.length; cnt++)
  {
    for(i = otlObjs.Folders(flds[cnt]).Items.Count; i >= 1; i--)
      if(otlObjs.Folders(flds[cnt]).Items(i).Unread && aqString.Trim(otlObjs.Folders(flds[cnt]).Items(i).SenderName) == sender)
        mItems[aqString.Trim(otlObjs.Folders(flds[cnt]).Items(i).Subject)] = (otlObjs.Folders(flds[cnt]).Items(i));
  }
 return mItems;
}

function saveAttachment(mailItem, path)//сохраняем из письма/писем attachment
// Входящий параметр - объект который возвращает getUnreadMail(otlAccount, sender)
// 
{
  if(!chkParams(mailItem))
    return false;
  
  var i, cnt;   
  var mItem;
  var path; //куда сохраняем.
  var fileName = []; //Сюда сохраним все названия вложений.
  
  path = path || ODT.Data.localparams.filesFolder;
  
  for(mItem in mailItem)  
    {
      cnt = mailItem[mItem].Attachments.Count;
      if(cnt > 0)
        {
          for(i = 1; i < cnt + 1; i++)
            {
              mailItem[mItem].Attachments(i).SaveAsFile(path + aqString.Trim(mItem.slice(aqString.Find(mItem, ":") + 1 )));
              fileName.push(mailItem[mItem].Attachments(i).FileName); 
            }           
        }  
    }
  return fileName;    
}     

function getMailSubject(mailItem)//Возвращает заголовок письма.
/*
*     Входящий параметр - объект, содержащий в себе письмо(одно, т.к. больше не надо.)
*/
{
  if(!chkParams(mailItem))
    return false;
  
  var elem;
  
  for(elem in mailItem)  
    return mailItem[elem].Subject; 
}

function getMailCreationTime(mailItem)//Время получения письма.
{
  if(!chkParams(mailItem))
    return false;
  
  var elem;
  
  for(elem in mailItem)  
    return aqConvert.DateTimeToStr(mailItem[elem].CreationTime);   
}

function otlSendAndReceive()//жмем кнопку получения\отправки письма
{
  getOleOutlook().SendAndReceive(false);
}

function getMailBySubject(subject)//получаем письмо по полю "Тема"(Subject)
/*
*   Входной параметр - тема письма
*   Возвращаемое значение - OLE объект, который является нашим письмом.
*
*   Работает так:
*   запускаем прием\отправку почты,
*   потом считываем все непрочитанные письма,
*   среди непрочитанных писем находим по заголовку нужное письмо и возвращаем его
*   если не нашлось, то возвращаем false  
*/
{
 
  var mails, mail = {};
  var elem;
  
  otlSendAndReceive();
  mails = getUnreadMail(адрес получателя, адрес отправителя); //TODO: поставить верные значения.
  
  for(elem in mails)
    if(aqString.Find(mails[elem].Subject, subject) != -1)
      {
        mail[elem] = mails[elem];
        return mail;
      }
      
  
  return false; 
}

function setMailReadStatus(mItem)//помечаем письмо/письма как прочтенное.
//Входящий параметр - объект наше письмо
{
  var elem;
  
  for(elem in mItem)
    mItem[elem].Unread = false;
}

function processMail(subject)//забираем атачмент из письма и помечаем как просмотренное
{
  var mItem;
  var fileName;
  
  mItem = getMailBySubject(subject);
  
  if(!mItem)
    return false;
  
  fileName = saveAttachment(mItem);
  setMailReadStatus(mItem);
  
  return {fileName: fileName,
          subj : getMailSubject(mItem),
          createTime : getMailCreationTime(mItem)}; //TODO: может не работать.
}