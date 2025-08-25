Vagrant.configure("2") do |config|
  # 1. Define the Virtual Machine
  config.vm.box = "arch-box"
  config.vm.box_check_update = false
  config.vm.hostname = "ansible-test-arch"
  # 2. Configure the Provider (libvirt/QEMU)
  config.vm.provider "libvirt" do |libvirt|
    libvirt.memory = "4096"
    libvirt.cpus = "2"
    libvirt.machine_type = 'q35'
    libvirt.loader = "/usr/share/edk2/x64/OVMF_CODE.4m.fd"
    libvirt.nvram = "/usr/share/edk2/x64/OVMF_VARS.4m.fd"
  end
  # 3. Provision the VM with Ansible
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbooks/main.yml"
    #ansible.inventory_path = "inventory.ini"
    ansible.become = true
    ansible.become_user = "root"
    ansible.verbose = "v"
    ansible.compatibility_mode = "2.0"
  end
end
