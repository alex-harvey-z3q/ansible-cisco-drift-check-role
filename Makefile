VENV = .venv

venv:
	python -m venv $(VENV)
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install -r requirements.txt
	$(VENV)/bin/pip install -r requirements-dev.txt
	$(VENV)/bin/ansible-galaxy collection install ansible.netcommon cisco.ios

lint:
	$(VENV)/bin/ansible-lint .

clean:
	rm -rf $(VENV)
