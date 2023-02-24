# Install-Update-Ksu-kernel-via-Ksu-manager
 - This module allows you to flash ksu kernel just in ksu manager./
 - 可以使用本模块在ksu管理器里对boot进行刷写
 
# Support
 - Backup&Restore boot / 备份/恢复boot
 - Flash kernel or boot.img / 刷写内核或boot(boot暂未测试)
 - Flash to target boot slot after OTA / 刷入ota后的槽位（重启前）

# How to use
 - clone this Repository
 - place the ksu kernel(or any other) in the root dir of this module
 - and rename it to Image
 - or ksu boot.img (or any other), rename it to boot.img
 - if you want to restore boot, donnot place any file
 - named Image in this folder
 - zip the whole folder and flash in ksu manager
//克隆仓库，把ksu内核命名为 Image 并放入模块根目录(或者是boot.img)，如果想要恢复boot则不要放进来
用zip压缩模块并在ksu管理器刷入


# Tools
 - magiskboot,bootctl 
 - all extracted from Magisk
 - 工具提取自magisk

# 注意
 - 备份文件为/data/adb/stock_boot_backup.img，不要随意删除
 - 不一定适合所有设备
 - 目前只在Redmi k60pro （gki2.0 5.15 vab）测试成功
 - 备份只会在ota后重启前或第一次刷这个模块
 - 备份boot只会保留本次刷写前对应分区的boot
 - ota后请只刷入一次ksu内核，否则可能破坏备份的官方boot
 - 恢复boot旨在系统更新前恢复原厂boot从而获取增量支持
 - 请手动做好备份，出现事故概不负责

 - 正在优化判断逻辑，八百年不一定更新一次
