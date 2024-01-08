#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <linux/platform_device.h>
#include <linux/sched.h>
#include <linux/io.h>
#include <linux/of.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/uaccess.h>
#include <linux/fs.h>

MODULE_LICENSE("GPL");

#define DEVNAME "GPU Module"

void *virtual_base;
#define HW_REGS_BASE ( 0xff200000 )
#define HW_REGS_SPAN ( 0x00200000 )
#define GPU_BASE ( 0x00000000 )

volatile int *GPU_ptr;

static int dev_uevent(struct device *dev, struct kobj_uevent_env *env) {
    add_uevent_var(env, "DEVMODE=%#o", 0222);
    return 0;
}

static int release(struct inode *inode, struct file *file);
static ssize_t write(struct file *file, const char __user *buf, size_t len, loff_t * offset);
static long ioctl(struct file *file, unsigned int cmd, unsigned long arg);

static struct file_operations fops = {
	.owner          = THIS_MODULE,
	.write          = write,
	.unlocked_ioctl = ioctl,
	.release        = release
};

dev_t dev = 0;
static struct class *dev_class;
static struct cdev cdev;

static struct task_struct* task = NULL ;

static long ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
    if (cmd == _IO('a', 'a') ) {
        task = get_current();
    }
    return 0;
}

static int release(struct inode *inode, struct file *file)
{
    struct task_struct *ref_task = get_current();
    if(ref_task == task) {
        task = NULL;
    }
    return 0;
}

static ssize_t write(struct file *file, const char __user *buf, size_t len, loff_t *offset)
{
    uint8_t databuf[len];

    copy_from_user(databuf, buf, len);
    int i = 0;
    for(i; i < len; i+=4) {
    	*GPU_ptr = ((uint32_t*)databuf)[i/4];
    }

    return len;
}

irq_handler_t irq_handler (int irq, void *dev_id, struct pt_regs * regs)
{
	struct kernel_siginfo info;

    if (task != NULL) {
        memset(&info, 0, sizeof(info));
        info.si_signo = 42;
        info.si_code = SI_QUEUE;
        send_sig_info(42, &info, task);
    }  

	return (irq_handler_t) IRQ_HANDLED;
}

static int init_handler(struct platform_device * pdev)
{
	alloc_chrdev_region(&dev, 0, 1, "gpu");
	cdev_init(&cdev,&fops);
    cdev_add(&cdev,dev,1);
    dev_class = class_create(THIS_MODULE,"gpu");
	dev_class->dev_uevent = dev_uevent;
    device_create(dev_class,NULL,dev,NULL,"gpu");
 
	int irq_num,ret;

	irq_num = platform_get_irq(pdev,0);

	ret = request_irq(irq_num, (irq_handler_t) irq_handler, 0, DEVNAME, NULL);
	printk(KERN_ALERT DEVNAME ": IRQ %d registered!\n", irq_num);

    virtual_base = ioremap(HW_REGS_BASE, HW_REGS_SPAN);
	GPU_ptr = virtual_base + GPU_BASE;

	return ret;
}
static int clean_handler(struct platform_device * pdev)
{
    device_destroy(dev_class,dev);
    class_destroy(dev_class);
    cdev_del(&cdev);
    unregister_chrdev_region(dev, 1);

	int irq_num;
	irq_num=platform_get_irq(pdev,0);

	free_irq(irq_num, NULL);
	return 0;
}

static const struct of_device_id my_module_id[] ={
	{.compatible = "altr,gpu"},
	{}
};

static struct platform_driver my_module_driver = {
	.driver = {
	 	.name = DEVNAME,
		.owner = THIS_MODULE,
		.of_match_table = of_match_ptr(my_module_id),
	},
	.probe = init_handler,
	.remove = clean_handler
};

module_platform_driver(my_module_driver);