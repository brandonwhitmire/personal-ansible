# Vagrantfile API/syntax version. Don't touch this.
Vagrant.configure("2") do |config|

  # 1. Define the Virtual Machine
  # ---------------------------------
  # Use the logical name of the box you just added.
  # Vagrant will find this in your local inventory.
  config.vm.box = "my-arch-box"

  # It's good practice to disable checking for updates for local boxes.
  config.vm.box_check_update = false

  # Define a hostname for the VM.
  config.vm.hostname = "ansible-test-arch"

  # 2. Configure the Provider (libvirt/QEMU)
  # ---------------------------------
  config.vm.provider "libvirt" do |libvirt|
    libvirt.memory = "2048"
    libvirt.cpus = "2"
  end

  # 3. Provision the VM with Ansible
  # ---------------------------------
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.inventory_path = "inventory.ini"
    ansible.become = true
    ansible.become_user = "root"
    ansible.verbose = "v"
  end
end
