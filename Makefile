

.PHONY: clean artifacts release link install test run cfntemplate docs

release: install test docs
	make artifacts

install: clean
	# Use the -e[dev] option to allow the code to be instrumented for code coverage
	pip install -e ".[dev]"
	jupyter serverextension enable --py sagemaker_run_notebook --sys-prefix

clean:
	rm -f sagemaker_run_notebook/cloudformation.yml
	rm -rf build/dist
	rm -rf docs/build/html/*

cfntemplate: sagemaker_run_notebook/cloudformation.yml

sagemaker_run_notebook/cloudformation.yml: sagemaker_run_notebook/cloudformation-base.yml sagemaker_run_notebook/lambda_function.py
	pyminify sagemaker_run_notebook/lambda_function.py | sed 's/^/          /' > /tmp/minified.py
	cat sagemaker_run_notebook/cloudformation-base.yml /tmp/minified.py > sagemaker_run_notebook/cloudformation.yml

artifacts: clean cfntemplate
	python setup.py sdist --dist-dir build/dist

test:
  # No python tests implemented yet
	# pytest -v .
	black --check .

docs:
	(cd docs; make html)
