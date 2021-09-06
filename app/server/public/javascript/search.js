(() => {
  const application = Stimulus.Application.start();

  application.register('search', class extends Stimulus.Controller {
    static targets = [
      'query',
      'clearFilter',
      'thumbnail',
    ];

    connect() {
      this.updateFilter();
    };

    get query() {
      if (this.hasQueryTarget) {
        return this.queryTarget.value;
      }
      return '';
    };

    updateFilter() {
      if (this.query !== '') {
        this.filterThumbnails(this.query);
      } else {
        this.showAll();
      }
    };

    clearFilter() {
      if (this.hasQueryTarget) {
        this.queryTarget.value = '';
        this.updateFilter();
      }
    };

    showAll() {
      this.thumbnailTargets.forEach((thumbnail) => {
        thumbnail.classList.remove('is-hidden');
      });
      if (this.hasClearFilterTarget) {
        this.clearFilterTarget.classList.remove('has-text-danger-dark');
      }
    };

    filterThumbnails(q) {
      this.thumbnailTargets.forEach((thumbnail) => {
        const name = thumbnail.dataset.thumbnailName.toLowerCase();
        if (name.includes(q.toLowerCase())) {
          thumbnail.classList.remove('is-hidden');
        } else {
          thumbnail.classList.add('is-hidden');
        }
      });
      if (this.hasClearFilterTarget) {
        this.clearFilterTarget.classList.add('has-text-danger-dark');
      }
    };
  });
})()
