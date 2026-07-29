install:
	pip install --upgrade pip && \
	pip install -r requirements.txt

format:
	black *.py

train:
	mkdir -p Results
	mkdir -p Model
	python train.py

eval:
	echo "## Model Metrics" > report.md
	cat ./Results/metrics.txt >> report.md
	echo "" >> report.md
	echo "## Confusion Matrix Plot" >> report.md
	echo "![Confusion Matrix](./Results/model_results.png)" >> report.md
	cml comment create report.md

update-branch:
	git config --global user.name "$(USER_NAME)"
	git config --global user.email "$(USER_EMAIL)"
	git add .
	git commit -m "Update with new results" || echo "No changes to commit"
	git push --force origin HEAD:update

hf-login:
	git pull origin update
	git switch update
	pip install -U "huggingface_hub[cli]"
	hf auth login --token $(HF) --add-to-git-credential

push-hub:
	hf upload iqranaz/Drug-Classification ./Model/drug_pipeline.skops drug_pipeline.skops --repo-type=model --commit-message="Sync Model weights"
	hf upload iqranaz/Drug-Classification ./App . --repo-type=space --commit-message="Sync App files"
	
deploy: hf-login push-hub