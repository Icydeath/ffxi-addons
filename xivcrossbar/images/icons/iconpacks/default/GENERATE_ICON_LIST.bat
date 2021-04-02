@echo off
dir /s/b/a-d > _iljunk.txt & BatchSubstitute.bat "%cd%\" "" _iljunk.txt > _iljunk2.txt & findstr /V /B /C:"ui" _iljunk2.txt | findstr /V /E /C:".bat" /C:".txt" /C:".svg" > icon_list.txt & del /f _iljunk.txt & del /f _iljunk2.txt
