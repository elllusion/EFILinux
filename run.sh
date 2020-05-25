#/bin/sh

# 使用qemu的bios

#输出日志到控制台
#qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd -enable-kvm -m 512M -serial  mon:stdio -net none -display sdl -drive format=raw,file=efilinux.img

# 输入日志到文件
if [[ -f run.log ]]; then
	mv run.log run-`date "+%Y-%m-%d_%H.%M.%S"`.log
fi
qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd -enable-kvm -m 512M -serial  file:run.log -net none -display sdl -drive format=raw,file=efilinux.img


# 使用实体机的bios
#  debug -》无法启动实体机的bios
#qemu-system-x86_64 -bios afuwin.rom -enable-kvm -m 512M -serial  mon:stdio -net none -display sdl -drive format=raw,file=efilinux.img