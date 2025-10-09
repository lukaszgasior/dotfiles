export async function checkAzureStatus() {
    try {
        const response = await fetch(`http://localhost:8787/azure-status?t=${Date.now()}`, {
            cache: 'no-store',
            headers: {
                'Cache-Control': 'no-cache',
                'Pragma': 'no-cache'
            }
        });
        const text = await response.text();
        const parser = new DOMParser();
        const xmlDoc = parser.parseFromString(text, "text/xml");

        const items = xmlDoc.getElementsByTagName('item');
        let status = {
            hasIssues: items.length > 0,
            issues: []
        };

        if (items.length > 0) {
            for (let i = 0; i < items.length; i++) {
                const item = items[i];
                status.issues.push({
                    title: item.getElementsByTagName('title')[0]?.textContent || '',
                    description: item.getElementsByTagName('description')[0]?.textContent || '',
                    category: item.getElementsByTagName('category')[0]?.textContent || '',
                    region: item.getElementsByTagName('az:tag')[0]?.textContent || ''
                });
            }
        }

        console.log(text)
        console.log("Azure status:", status);

        return status;
    } catch (error) {
        console.error('Error fetching Azure status:', error);
        return { hasIssues: false, error: true };
    }
}
