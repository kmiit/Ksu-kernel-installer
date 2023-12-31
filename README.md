# Install-Update-Ksu-kernel-via-Ksu-manager
 - 可以使用本模块在ksu管理器里对boot进行刷写
 
# Support
 - 备份/恢复boot
 - 刷写内核或boot
 - 刷入ota后的槽位（重启前）

# How to use
 - 克隆仓库/下载source
 - 把与手机对应的ksu内核命名为 Image 并放入模块根目录(或者是直接用对应的boot.img)
 - 如果想要恢复之前备份的boot则不要任何其他文件放进来
 - 用zip压缩整个模块根目录并在ksu管理器刷入这个zip

# Tools
 - magiskboot以及bootctl工具提取自magisk

# 注意
 - 备份文件为`/data/adb/stock_boot_backup.img`，不要随意删除
 - 不一定适合所有设备（理论支持所有米系vab设备，a only可能不太友好，没机子测试）
 - 所有功能测试成功机型: Redmi K60Pro, Redmi K50, Xiaomi 12Pro ~~(最后一次push未做测试)~~
 - 备份boot只会保留本次刷写前对应分区的boot
 - ota后请只刷入一次ksu内核，否则可能破坏备份的官方boot
 - 恢复boot旨在系统更新前恢复原厂boot从而获取增量支持（好久没测试了）
 - 请手动做好备份，出现事故概不负责

 - 正在优化判断逻辑，八百年不一定更新一次
