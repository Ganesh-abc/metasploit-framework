# -*- coding: binary -*-
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../../lib')))
require 'msf/core/build_vuln'

puts "[*] --- Integrated Vim RCE Automation Test ---"
builder = Msf::BuildVuln.new('msf-vim-target')

# 1. Start the container
puts "[*] Starting the victim container..."
container_id = builder.start

if container_id
  begin
    # 2. Inject the exploit
    puts "[*] Injecting exploit.txt into container #{container_id[0...12]}..."
    system("sudo docker cp tools/dev/vulnerable_targets/vim_rce/exploit.txt #{container_id}:/home/victim/exploit.txt")

    # 3. Trigger the exploit / Read the file
    puts "[*] Triggering Vim modeline read..."
    # We use -u /etc/vim/vimrc to FORCE Vim to use our vulnerable config
    # We use --not-a-term to prevent Vim from complaining about no TTY
    trigger_cmd = "vim -u /etc/vim/vimrc --not-a-term -c 'set modeline' -c 'redir! > /tmp/vim_result' -c 'set textwidth?' -c 'redir END' -c 'quit' /home/victim/exploit.txt"
    system("sudo docker exec #{container_id} bash -c \"#{trigger_cmd}\" > /dev/null 2>&1")

    # 4. Verifying if the modeline was processed
    puts "[*] Verifying Modeline processing..."
    result = `sudo docker exec #{container_id} cat /tmp/vim_result 2>/dev/null`.strip

    if result.include?("1337")
      puts "[+] SUCCESS: Modeline confirmed! Vim processed the injected setting (textwidth=1337)."
    else
      puts "[-] FAILED: Vim did not process the modeline. Result was: '#{result}'"
    end

  ensure
    # 5. Cleanup
    builder.cleanup
    puts "[*] Environment cleaned up."
  end
else
  puts "[-] Failed to start container."
end
