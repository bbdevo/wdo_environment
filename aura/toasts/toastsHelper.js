({
    showToast: function(component, toast) {
        switch (toast.type) {
            case 'error':
                toast.iconName = 'utility:error';
                break;
            case 'warning':
                toast.iconName = 'utility:warning';
                break;
            case 'success':
                toast.iconName = 'utility:success';
                break;
            case 'info':
                toast.iconName = 'utility:info';
                break;
            default:
                toast.type = 'other';
                toast.iconName = toast.key;
        }

        if ('sticky' != toast.mode) {
            if ($A.util.isEmpty(toast.duration)) {
                toast.duration = 5000;
            }
        }

        $A.createComponent('c:toast', {
            toast: toast,
            onUnrender: component.getReference('c.updateToasts')
        }, (toastComponent, status, errorMessage) => {
            if (component.isValid()) {
                if ('SUCCESS' == status) {
                    var toasts = component.get('v.toasts');
                    toasts.unshift(toastComponent);

                    component.set('v.toasts', toasts);

                    this.updateToasts(component);
                }
            }
        });
    },
    updateToasts: function(component) {
        var toasts = component.get('v.toasts');

        toasts = toasts.filter(toast => {
            return toast.isValid();
        }).reverse();

        if (toasts.length) {
            toasts.forEach((toast, i) => {
                if (3 > i) {
                    toast.show();
                }
            });
        } else {
            component.set('v.toasts', []);
        }
    }
})