# Install-Update-Ksu-kernel-via-Ksu-manager
 - This module allows you to flash ksu kernel just in ksu manager./
 - 可以使用本模块在ksu管理器里对boot进行刷写
 
# Support
 - Backup&Restore boot / 备份/恢复boot
 - Flash target boot slot after OTA / 刷入ota后的槽位（重启前）

# How to use
 - place the ksu kernel in the root dir of this module
 - and rename it to Image
 - if you want to restore boot, donnot place any file
 - named Image in this folder
 - zip the whole folder and flash in ksu manager
//把ksu内核命名为 Image 并放入模块根目录（如果是恢复boot则不要放进来）
用zip压缩模块并在ksu管理器刷入


# Tools
 - magiskboot,bootctl 
 - all extracted from Magisk
 - 工具提取自magisk

# 注意
 - 不一定适合所有设备
 - 目前只在Redmi k60pro （gki2.0 5.15 vab）测试成功
 - OTA后刷入目前测试成功一次
 - ota后备份boot只会保留本次刷写前对应分区的boot
 - ota后请只刷入一次ksu内核，否则可能破坏备份的官方boot
 - 恢复boot暂未测试，也许会失败
 - 请手动做好备份，出现事故概不负责

 - 正在优化判断逻辑，八百年不一定更新一次