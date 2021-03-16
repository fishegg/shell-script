pre_pkg=
pkg_tmp=
pkg=
set_package_input()
{
  #1
  #pkg=
  if [[ ${pre_pkg} ]]
    then echo last .apk file:
      echo ${pre_pkg}
      echo and type p to select
  fi
  if [[ ${pkg} ]]
    then pkg_tmp=${pkg}
  fi
  echo .apk file path: 
  read pkg 
  if [[ ${pkg} = p ]]; then
    pkg=${pre_pkg}
    pre_pkg=${pkg_tmp}
    return 2
  fi
  if [[ ! ${pkg} ]]; then
    echo No file set.
    return 1
  fi
  if [[ ! ${pkg} ]]; then
    echo No such file.
    return 1
  fi
  pre_pkg=${pkg}
  return 2
}

set_package_name()
{
  #2
  suffix=${pkg##*.}
  #for %%i in ("%suffix%") do suffix=%%~xi
  if [[ ${suffix} != apk ]]; then
    echo ${pkg} is not a .apk file.
    return 1
  fi
  if [[ ! ${pkg_tmp} ]]; then
    return 3
  fi
  if [[ ${pkg_tmp} != ${pkg} ]]; then
    pre_pkg=${pkg_tmp}
    return 3
  fi
  return 3
}

pkg_name=
skip_pkg_tmp()
{
  #3
  pkg_name=
  if [[ ${serial} ]]; then
    return 6
  fi
  return 4
}

select_device()
{
  #4
  #rem serial=
  retry_time=0
  retry_times=3
  device=
  abi=
  echo=
  echo devices:
  adb devices|grep -E "device$|unauthorized|offline"|grep -E -n "device$|unauthorized|offline"
  #rem /p device=device: 
  if [[ ${serial} ]]; then
    #choice /c 1235670rc /m "device(press r to refresh list or press c to reconnect to ${serial}): " /n
    echo "device(press r to refresh list or press c to reconnect to ${serial}): "
    read device
    if [[ ${device} =~ ${pattern1} ]]; then
      #redo
      return 4
    fi
  fi
  if [[ ! ${serial} ]]; then
    #choice /c 1235670rc /m "device(press r to refresh list): " /n
    echo "device(press r to refresh list): "
    read device
    if [[ ${device} =~ ${pattern2} ]]; then
      #redo
      return 4
    fi
  fi
  #device=${errorlevel}
  if [[ ! ${device} ]]; then
    echo No device selected.
    return 4
  fi
  if [[ ${device} = c ]];then
    adb -s ${serial} reconnect
    #timeout /t 5
    sleep 5
    return 4
  fi
  if [[ ${device} = r ]]; then
    return 4
  fi
  return 5
  #rem /a device+=1
}

check_device()
{
  #5
  adb devices|grep -E "device$|unauthorized|offline" > wechatfilegen.tmp
  device=`awk '{ print $1,NR,$2 }' wechatfilegen.tmp|grep " ${device} "`
  serial=`echo $device|awk '{ print $1 }'`
  type=`echo $device|awk '{ print $3 }'`
  #echo $serial and $type
  if [[ ! ${serial} ]]; then
    echo No such devices.
    return 4
  fi
  if [[ ! ${type} ]]; then
    echo No such devices.
    return 4
  fi
  let retry_time+=1
  if [[ ${type} = unauthorized ]]; then
    echo ${retry_time}/${retry_times} times of retry
    if [[ ${serial:0:3} != 172 ]]
      then adb -s ${serial} reconnect #& timeout /t 5
      sleep 5
    fi
    if [[ ${serial:0:3} = 172 ]]
      then adb -s ${serial} disconnect & adb connect ${serial} #& timeout /t 5
      sleep 5
      echo=
    fi
    if [[ ! ${retry_time} = ${retry_time} ]]
      then return 5
    fi
    return 5
  fi
  model=`adb -s ${serial} shell getprop ro.product.model`
  release=`adb -s ${serial} shell getprop ro.build.version.release`
  abi=`adb -s ${serial} shell getprop ro.product.cpu.abi`
  #if exist %~dp0\strlen.bat (
   # call %~dp0\strlen.bat "${serial} (${model} Android ${release})"
    #if !errorlevel! leq 60 (/a non_model_len=66-!errorlevel!) else non_model_len=
    #call %~dp0\strlen.bat "${abi}"
    #/a non_abi_len=70-!errorlevel!
    #rem echo !non_abi_len!
  #)
  #title=${model}
  return 6
}

tool=
select_tool()
{
  #6
  pattern3="[^irauctpskdfgwq]"
  echo=
  #echo ${date} ${time}
  date +%F" "%T
  echo +-----------------------------------------------------------------------------------+
  echo \|Current file: ${pkg}
  echo \|Current package name: ${pkg_name}
  echo \|Current device: ${serial} \(${model}\)
  echo \|Device abi: ${abi}
  echo \|i.Install   r.Replace install   a.Uninstall \& install   u.Uninstall   c.Clear data \|
  echo \|t.Input text   p.Input tap   s.Input swipe   k.Change package   d.Change device    \|
  echo \|f.force stop   g.grant storage permission   q.quit                                 \|
  echo +-----------------------------------------------------------------------------------+
  #choice /c irauctpskdfgw /m "tool: " /n
  echo tool:
  read tool
  if [[ ${tool} =~ ${pattern3} ]]; then
    return 6
  fi
  return 7

}

jump_to_tool()
{
  #7
  if [[ ${tool} = i ]]; then return 9;fi
  if [[ ${tool} = r ]]; then return 10;fi
  if [[ ${tool} = a ]]; then return 11;fi
  if [[ ${tool} = u ]]; then return 12;fi
  if [[ ${tool} = c ]]; then return 13;fi
  if [[ ${tool} = t ]]; then return 14;fi
  if [[ ${tool} = p ]]; then return 15;fi
  if [[ ${tool} = s ]]; then return 16;fi
  if [[ ${tool} = k ]]; then return 1;fi
  if [[ ${tool} = d ]]; then return 4;fi
  if [[ ${tool} = f ]]; then return 17;fi
  if [[ ${tool} = g ]]; then return 18;fi
  if [[ ${tool} = w ]]; then return 19;fi
  if [[ ${tool} = q ]]; then exit;fi
  return 6
}

install()
{
  #9
  #echo on
  #if [[ ${model} = V1818CA ]]; then start %~dp0\vivoinstall.bat ${serial} 1
  #if [[ ${model} = PCT-AL10 ]]; then start %~dp0\huaweiinstall.bat ${serial} 1
  #adb -s ${serial} install --abi ${abi} ${pkg}
  adb -s ${serial} install ${pkg}
  return 6
}

replace_install()
{
  #10
  #echo on
  #if [[ ${model} = V1818CA ]]; then start %~dp0\vivoinstall.bat ${serial} 1
  #if [[ ${model} = PCT-AL10 ]]; then start %~dp0\huaweiinstall.bat ${serial} 1
  #adb -s ${serial} install --abi ${abi} -r ${pkg}
  adb -s ${serial} install -r ${pkg}
  return 6
}

un_install()
{
  #11
  #echo on
  adb -s ${serial} uninstall ${pkg_name}
  #if [[ ${model} = V1818CA ]]; then start %~dp0\vivoinstall.bat ${serial} 1
  #if [[ ${model} = PCT-AL10 ]]; then start %~dp0\huaweiinstall.bat ${serial} 1
  #adb -s ${serial} install --abi ${abi} ${pkg}
  adb -s ${serial} install ${pkg}
  return 6
}

uninstall()
{
  #12
  #echo on
  adb -s ${serial} uninstall ${pkg_name}
  return 6
}

clear_data()
{
  #13
  choice=
  pattern4="[^cxq]"
  #choice /c cxq /n /m "press c to clear only app or press x to clear app and play or press q to quit"
  echo "press c to clear only app or press x to clear app and play or press q to quit"
  #@choice=${errorlevel}
  #read choice
  if [[ ${choice} =~ ${pattern4} ]]; then
    return 13
  fi
  if [[ ${choice} = q ]]; then
    return 6
  fi
  #rem echo ${choice}
  ##echo on
  adb -s ${serial} shell pm clear ${pkg_name}
  if [[ ${choice} = x ]]; then
    adb -s ${serial} shell pm clear com.android.vending
    if [[ ${pkg_name} = com.recorder.video.magic.capture.gameplay ]]
    then
      adb -s ${serial} shell pm clear com.android.vending
      adb -s ${serial} shell am start com.android.vending/com.android.vending.AssetBrowserActivity
      adb -s ${serial} shell rm -r /sdcard/CaptureScreenRecorder/.subs
    fi
    if [[ ${pkg_name} = qr.code.barcode.maker.scanner.reader ]]
    then
      adb -s ${serial} shell rm -r /sdcard/ScannerReader/.subs
    fi
    if [[ ${pkg_name} = com.jb.screenrecorder.screen.record.video ]]
    then
      adb -s ${serial} shell rm -r /sdcard/GOScreenRecorder/.subs
    fi
    #adb -s ${serial} shell am start com.android.vending/com.android.vending.AssetBrowserActivity
  fi
  return 6
}

input_text()
{
  #14
  echo=
  echo device: ${serial}
  text=
  echo type text or type c to change device or type t to change tool:
  read text
  if [[ ! ${text} ]]; then
    echo Error input text
  fi
  if [[ ${text} = c ]]
  then
    return 4
  fi
  if [[ ${text} = t ]]
  then
    return 6
  fi
  if [[ ${text} ]]; then
    adb -s ${serial} shell input text \"${text}\"
  fi
  return 14
}

input_tap()
{
  #15
  echo=
  echo device: ${serial}
  times=
  echo type tapping times or type c to change device or type t to change tool:
  read times
  if [[ ! ${times} ]]; then
    echo Times not set
    return 15
  fi
  if [[ ${times} = c ]]; then
    return 4
  fi
  if [[ ${times} = t ]]; then
    return 6
  fi
  coordinate=
  echo coordinate\(x y\):
  read x y 
  if [[ ! ${times} ]]; then
    echo Coordinate not set
    return 15
  fi
  count=0
  for (( count = 0; count < ${times}; count++ )); do
    adb -s ${serial} shell input tap ${x} ${y}
    echo ${count}/${times} taps ${x},${y} @ ${serial}
  done
  return 15
}

input_swipe()
{
  #16
  echo=
  echo device: ${serial}
  times=
  echo type swiping times or type c to change device or type t to change tool:
  /p times=
  if [[ ! ${times} ]]; then
    echo Times not set.
    return 16
  fi
  if [[ ${times} = c ]]; then return 4; fi
  if [[ ${times} = t ]]; then return 6; fi
  count=0
  x=
  echo xmax\(default 1080\):
  read xmax
  if [[ ! ${xmax} ]]; then
    xmax=1080
    echo xmax to 1080
  fi
  y=
  echo ymax\(default 1800\):
  read ymax
  if [[ ! ${ymax} ]]; then
    ymax=1800
    echo ymax to 1800
  fi
  for (( count = 0; count < $times; count++ )); do
    let x1=${RANDOM}%${xmax}
    let x2=${RANDOM}%${xmax}
    let y1=${RANDOM}%${ymax}
    let y2=${RANDOM}%${ymax}
    adb -s ${serial} shell input swipe ${x1} ${y1} ${x2} ${y2} 30
    echo ${count}/${times} swipes @${serial} \(${x1},${y1}\)-\>\(${x2},${y2}\)
  done
  return 16
}

force_stop()
{
  #17
  #echo on
  adb -s ${serial} shell am force-stop ${pkg_name}
  #@echo off
  return 6
}

grant_permission()
{
  #18
  #echo on
  adb -s ${serial} shell pm grant ${pkg_name} android.permission.READ_EXTERNAL_STORAGE
  adb -s ${serial} shell pm grant ${pkg_name} android.permission.WRITE_EXTERNAL_STORAGE
  #@echo off
  return 6
}

wake_up()
{
  #19
  #echo on
  adb -s ${serial} shell input keyevent 26
  sleep 1
  adb -s ${serial} shell input swipe 600 600 50 50 56
  #@echo off
  return 6
}

retry_time=0
retry_times=3
serial=
device=
abi=
echo=
pattern1="[^0-9rc]"
pattern2="[^0-9r]"
flag=1
flag=1
while(true)
do
  #echo flag=$flag
  #read -p press anykey to continue. 
  case $flag in
    1 )set_package_input ; flag=$?;;
    2 )set_package_name ; flag=$?;;
    3 )skip_pkg_tmp ; flag=$?;;
    4 )select_device ; flag=$?;;
    5 )check_device ; flag=$?;;
    6 )select_tool ; flag=$?;;
    7 )jump_to_tool ; flag=$?;;
    8 )a1 ; flag=$?;;
    9 )install ; flag=$?;;
    10 )replace_install ; flag=$?;;
    11 )un_install ; flag=$?;;
    12 )uninstall ; flag=$?;;
    13 )clear_data ; flag=$?;;
    14 )input_text ; flag=$?;;
    15 )input_tap ; flag=$?;;
    16 )input_swipe ; flag=$?;;
    17 )force_stop ; flag=$?;;
    18 )grant_permission ; flag=$?;;
    19 )wake_up ; flag=$?;;
  esac
done