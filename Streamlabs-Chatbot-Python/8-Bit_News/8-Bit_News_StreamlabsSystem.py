# -*- coding: UTF-8 -*-

#---------------------------
#   Import Libraries
#---------------------------
import os
import sys
import json
sys.path.append(os.path.join(os.path.dirname(__file__), "lib")) #point at lib folder for classes / references

import clr
clr.AddReference("IronPython.SQLite.dll")
clr.AddReference("IronPython.Modules.dll")

#   Import io module for reading text files in UTF-8 encoding correctly
import io

#   Import your Settings class
from Settings_Module import MySettings
#---------------------------
#   [Required] Script Information
#---------------------------
ScriptName = "8-Bit Tea Party News"
Website = "https://github.com/dreamy-cat/8-Bit-Tea-Party"
Description = "'nn' command will pop a news from the News.txt (like from stack) in chat"
Creator = "MustangDSG"
Version = "0.0.1.8"

#---------------------------
#   Define Global Variables
#---------------------------
global SettingsFile
SettingsFile = ""
global ScriptSettings
ScriptSettings = MySettings()
NEWS_FILE = os.path.dirname(__file__)+"\\News\\News.txt" #path to the news file
POPPED_NEWS_FILE = os.path.dirname(__file__)+"\\News\\Popped_news.txt" #path to the file with news which was popped
NO_MORE_NEWS = u"Новостей больше нет"

#---------------------------
#   [Required] Initialize Data (Only called on load)
#---------------------------
def Init():

    #   Create Settings Directory
    directory = os.path.join(os.path.dirname(__file__), "Settings")
    if not os.path.exists(directory):
        os.makedirs(directory)

    #   Load settings
    SettingsFile = os.path.join(os.path.dirname(__file__), "Settings\\settings.json")
    ScriptSettings = MySettings(SettingsFile)
    return

#---------------------------
#   [Required] Send Message to Chat / Process messages
#---------------------------

def Log(message): # for debugging
    Parent.Log(ScriptName, message)

def ReadLineFromTheTextFile(textFile = NEWS_FILE):
    tFile = io.open(textFile, "r", encoding="utf-8")
    line = tFile.readline()
    tFile.close()
    
    return line

def WriteLineToEndOfTheTextFile(textFile = POPPED_NEWS_FILE, line = ""):
    tFile = io.open(textFile, "a", encoding="utf-8")
    tFile.writelines(line)
    tFile.close()

def DeleteFirstLineOfTheTextFile(textFile = NEWS_FILE):
    with open(textFile) as tFile:
        lines = tFile.readlines()[1::] # all lines to keep except first
    
    with open(textFile, 'w') as tFile:
        tFile.writelines(lines)

def SendNewsToChat(newsFile = NEWS_FILE, poppedNewsFile = POPPED_NEWS_FILE, noMoreNewsText = NO_MORE_NEWS):
    
    lineOfTextOfTheNews = "" # for popping just text of the news to text file
    newsToSend = ""
    
    for i in range(2):
        if i == 0:
            newsToSend = ReadLineFromTheTextFile(newsFile)
            if newsToSend != "":
                WriteLineToEndOfTheTextFile(poppedNewsFile, newsToSend)
        else:
            lineOfTextOfTheNews = ReadLineFromTheTextFile(newsFile)
            
            if newsToSend != "":
                newsToSend += "\n" + lineOfTextOfTheNews
                if lineOfTextOfTheNews != "":
                    WriteLineToEndOfTheTextFile(poppedNewsFile, lineOfTextOfTheNews)
        
        DeleteFirstLineOfTheTextFile(newsFile)    
    
    if newsToSend == "":
        newsToSend = noMoreNewsText

    return newsToSend

#---------------------------
#   [Required] Execute Data / Process messages
#---------------------------
def Execute(data):
    if data.IsChatMessage() and data.GetParam(0).lower() == ScriptSettings.Command and Parent.IsOnUserCooldown(ScriptName,ScriptSettings.Command,data.User):
        Parent.SendStreamMessage("Time Remaining " + str(Parent.GetUserCooldownDuration(ScriptName,ScriptSettings.Command,data.User)))

    #   Check if the propper command is used, the command is not on cooldown and the user has permission to use the command
    if data.IsChatMessage() and data.GetParam(0).lower() == ScriptSettings.Command and not Parent.IsOnUserCooldown(ScriptName,ScriptSettings.Command,data.User) and Parent.HasPermission(data.User,ScriptSettings.Permission,ScriptSettings.Info):
        Parent.BroadcastWsEvent("EVENT_MINE","{'show':false}")
        Parent.SendStreamMessage(SendNewsToChat(NEWS_FILE, POPPED_NEWS_FILE))    # Send news to chat
        Parent.AddUserCooldown(ScriptName,ScriptSettings.Command,data.User,ScriptSettings.Cooldown)  # Put the command on cooldown

    
    return

#---------------------------
#   [Required] Tick method (Gets called during every iteration even when there is no incoming data)
#---------------------------
def Tick():
    return

#---------------------------
#   [Optional] Parse method (Allows you to create your own custom $parameters) 
#---------------------------
def Parse(parseString, userid, username, targetid, targetname, message):
    
    if "$myparameter" in parseString:
        return parseString.replace("$myparameter","I am a cat!")
    
    return parseString

#---------------------------
#   [Optional] Reload Settings (Called when a user clicks the Save Settings button in the Chatbot UI)
#---------------------------
def ReloadSettings(jsonData):
    # Execute json reloading here
    ScriptSettings.__dict__ = json.loads(jsonData)
    ScriptSettings.Save(SettingsFile)
    return

#---------------------------
#   [Optional] Unload (Called when a user reloads their scripts or closes the bot / cleanup stuff)
#---------------------------
def Unload():
    return

#---------------------------
#   [Optional] ScriptToggled (Notifies you when a user disables your script or enables it)
#---------------------------
def ScriptToggled(state):
    return
