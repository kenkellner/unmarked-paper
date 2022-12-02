docker:
	docker image build -t unmarked-paper .
	$(eval ID = $(shell docker create unmarked-paper))
	mkdir -p docker-output
	rm -f docker-output/*
	docker cp $(ID):/unmarked-paper/unmarked_Paper_Analysis.html docker-output/
	docker cp $(ID):/unmarked-paper/Figure_4.tiff docker-output/
	docker rm -v $(ID)
