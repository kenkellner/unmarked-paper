docker:
	docker image build -t unmarked-paper .
	$(eval ID = $(shell docker create unmarked-paper))
	rm -rf docker-output
	mkdir -p docker-output
	docker cp $(ID):/unmarked-paper/unmarked_Paper_Analysis.html docker-output/
	docker cp $(ID):/unmarked-paper/Figure_4.tiff docker-output/
	docker rm -v $(ID)
