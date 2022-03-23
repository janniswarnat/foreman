Clone the send_humidity private repo:
  git.latest:
    - name: https://github.com/janniswarnat/send_humidity.git
    - target: /home/pi/github/send_humidity
    - https_user: janniswarnat
    - https_pass: {{ pillar['git-personal-access-token'] }}
